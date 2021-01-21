require "spec_helper"
require "fileutils"

RSpec.describe Asciidoctor::MPFA do
  context "when xref_error.adoc compilation" do
    around do |example|
      FileUtils.rm_f "spec/assets/xref_error.err"
      example.run
      Dir["spec/assets/xref_error*"].each do |file|
        next if file.match?(/adoc$/)

        FileUtils.rm_f(file)
      end
    end

    it "generates error file" do
      expect do
        Metanorma::Compile
          .new
          .compile("spec/assets/xref_error.adoc", type: "mpfa", :"agree-to-terms" => true)
      end.to(change { File.exist?("spec/assets/xref_error.err") }
              .from(false).to(true))
    end
  end

      it "Warns of illegal doctype" do
          FileUtils.rm_f "test.err"
    Asciidoctor.convert(<<~"INPUT", backend: :mpfa, header_footer: true)
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :no-isobib:
  :doctype: pizza

  text
  INPUT
    expect(File.read("test.err")).to include "pizza is not a recognised document type"
end

      it "Warns of illegal status" do
          FileUtils.rm_f "test.err"
    Asciidoctor.convert(<<~"INPUT", backend: :mpfa, header_footer: true)
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :no-isobib:
  :status: pizza

  text
  INPUT
    expect(File.read("test.err")).to include "pizza is not a recognised status"
end

end
