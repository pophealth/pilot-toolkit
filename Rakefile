require 'rake/testtask'

namespace :xml do
  desc "Compile a set of schematron rules into a stylesheet. Use SCH_FILE to specify the location of the rules"
  task :sch_compile do
    raise 'must pass SCH_FILE' unless ENV['SCH_FILE']
    saxon_startup = "java -cp jars/saxon9.jar:jars/saxon9-dom.jar net.sf.saxon.Transform"
    sh "#{saxon_startup} -s:#{ENV['SCH_FILE']} -xsl:resources/schematron/compiler/iso_dsdl_include.xsl -o:temp1.xml"
    sh "#{saxon_startup} -s:temp1.xml -xsl:resources/schematron/compiler/iso_abstract_expand.xsl -o:temp2.xml"
    rm "temp1.xml"
    sh "#{saxon_startup} -s:temp2.xml -xsl:resources/schematron/compiler/iso_svrl_for_xslt2.xsl -o:result.xslt phase=errors"
    rm "temp2.xml"
  end
end

Rake::TestTask.new do |t|
    t.libs << "test"
    t.test_files = FileList['test/*.rb']
    t.verbose = true
end