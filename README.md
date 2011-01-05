This project will contain tools to help pilot the popHealth project. This includes tools to:

* Validate a HITSP C32 using XML Schema and Schematron rules
* POST documents into the popHealth web application

Setup
-----

This project needs to be run using [JRuby](http://jruby.org/). This allows for easy XML schema validation and running XSLT on any platform. This project also uses [Saxon](http://saxon.sourceforge.net/). To make sure that you can run the code correctly, you must set a CLASSPATH environment variable to ensure that Saxon is loaded into the execution environment. This can be done by issuing the following command:

    export CLASSPATH=jars/saxon9.jar:jars/saxon9-dom.jar

Testing
-------

This project has a very basic test suite that relies on Test::Unit. It can be run with

    rake test
