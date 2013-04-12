# conjoiners - multi-platform / multi-language reactive programming library

conjoiners is a library aiming to enable reactive programming for
existing (or new) systems written in different languages and running
on different platforms. conjoiners is minimally invasive in its
programming model, but complex behind the scenes.

Idea and first implementations are done by me, Pavlo Baron (pavlobaron).

This is the Ruby implementation. General project description can be
found in the [conjoiners repository](https://github.com/conjoiners/conjoiners).

## How does it work?

conjoiners for Ruby follows the conjoiners simplicity of use an
non-invasiveness. In order to add an implant to an object, you call:

    require 'conjoiners'
    Conjoiners::implant(@cj1, "./conf.json", "test") 

From here, any time you set a field value in this object, a
transenlightenment will be propagated to all known conjoiners. Any
time you access a value, it will return the most current one,
eventually set through a transenlightenment from other
conjoiner. That's basically it.

Internally, conjoiners for Ruby works by redefining the existing setter methods.
This is done for all setter methods in the instance to implant.
Every time you set a value for an instance variable the new value will be published
and afterwards the original setter method will be called.

Data changes from other conjoiners are received through subscriptions. If you have 
defined an onTransenlightenment method this method will be automatically called on 
data change. For now threads are used to implement the receiving logic. Unfortunately 
the use of GIL prevents real parallel computation. A better solution is not implemented
yet. Libraries like EventMachine could help to enable real parallel computation.

This library brings ffi-rzmq and json as dependency.

To run the tests, first install the dependencies using gem install, afterwards run the
tests within the test directory.
    
    gem install ffi-rzmq
    gem install json
    ruby test_conjoiner.rb
