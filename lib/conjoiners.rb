#
# This file is part of conjoiners
#
# Copyright (c) 2013 by Pavlo Baron (pb at pbit dot org)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'ffi-rzmq'
require 'json'

module Conjoiners

  class Implanter

    SET = "set_"

    def initialize
      @ctxs = {}
      @exts = {}
    end

    def implant(o, conf, name)
      ctx = ensure_ctx(o)
      url = my_url(conf, name)
      con = bind_external(ctx, o, url)
      vars = hook_instance_variables(con, o, name)
      connect_to_conjoiners(ctx, o, conf, name, vars)
    end

    # bind to the external url
    def bind_external(ctx, o, url)
      if !@exts.has_key?(o.object_id)
        ext_sock = ctx.socket(ZMQ::PUB)
        ext_sock.setsockopt(ZMQ::LINGER, 1)
        ext_sock.bind(url)
        @exts[o.object_id] = ext_sock
      else
        ext_sock = @exts[o.object_id]
      end
      return ext_sock
    end

    # encode key
    def key_n(n)
        return SET + n
    end

    # pack payload as json, e.g. in order to send it
    def pack_payload_single(name, n, v)
      return "{\"sender\": \"" + name + "\", \"time\": \"" + Time.now.to_i.to_s + "\", \"" + key_n(n) + "\": \"" + v + "\"}"
    end

    # unpack name and value from payload
    def unpack_payload_single(payload)
      o = JSON.parse(payload)
      o.keys.each do | k |
        if (k =~ /^#{SET}.*/)
          v = o[k]
          k = k.gsub(/^#{SET}/, "")
          return [k, v]
        end
      end
    end

    # hook all instance variables, override their setters
    private
    def hook_instance_variables(con, o, name)
      vars = {}

      # retrieve eigenclass
      metaclass = class << o; self; end

      for symbol in o.class.public_instance_methods(false)
        n = symbol.to_s
        if n =~ /.*=$/
          next
        end

        # retrieve original setter in order to call it afterwards
        m = o.method(n + "=")
        overrideSetter(metaclass, self, n, m, con, name)

        vars[n] = m
      end
      return vars
    end

    private
    def overrideSetter(metaclass, implanter, n, method, con, name)
        metaclass.send(:define_method, n + "=") do | v |
          # publish new value
          con.send_string(implanter.pack_payload_single(name, n, v), ZMQ::NonBlocking)

          # call original setter
          method.call(v)
        end
    end

    # connect to other conjoiners
    private
    def connect_to_conjoiners(ctx, o, conf, name, vars)
      for c in conf["conjoiners"] do
        if c["name"] != name
          Thread.new(c["url"]) do |url|
            sub_sock = ctx.socket(ZMQ::SUB)
            sub_sock.setsockopt(ZMQ::LINGER, 1)
            sub_sock.setsockopt(ZMQ::SUBSCRIBE,'')
            sub_sock.connect(url)

            while true
              payload = ''
              sub_sock.recv_string(payload)
              nv = unpack_payload_single(payload)
              vars[nv[0]].call(nv[1])
            end
          end
        end
      end
    end

    private
    def ensure_ctx(o)
      if !@ctxs.has_key?(o.object_id)
        ctx = ZMQ::Context.create(1)
        @ctxs[o.object_id] = ctx
      else
        ctx = @ctxs[o.object_id]
      end
      return ctx
    end

    private
    def my_url(conf, name)
      for c in conf["conjoiners"]
        if name == c["name"]
          return c["url"]
        end
      end
    end

  end

  def self.implant(o, cfg_file, my_name)
    json = File.read(cfg_file)
    conf = JSON.parse(json)
    if !@implanter
      @implanter = Implanter.new
    end
    @implanter.implant(o, conf, my_name)
  end

end
