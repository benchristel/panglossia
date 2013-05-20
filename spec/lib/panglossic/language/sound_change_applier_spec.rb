require 'spec_helper'

describe Panglossic::Language::SoundChangeApplier do
  let(:sca) { Panglossic::Language::SoundChangeApplier.new }
  
  context "with no input" do
    it "passes words through unchanged" do
      sca.change("qwerty").should eq "qwerty"
    end
  end
end
