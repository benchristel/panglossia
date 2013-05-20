require 'spec_helper'

describe Panglossic::Language::Lexicon do
  let(:lexicon_options) { {} }
  
  context ".new" do
    let(:lexicon) { Panglossic::Language::Lexicon.new }
    it "maps glosses to themselves" do
      lexicon.lookup("foo").should eq "foo"
    end
    
    context "with input" do
      let(:lexicon) { Panglossic::Language::Lexicon.new input, lexicon_options }
      
      context "containing one entry" do
        let(:input) { "bladvak: pickaxe" }
        
        it "sound-changes the gloss" do
          Panglossic::Language::SoundChangeApplier.any_instance.should_receive(:change).with("bladvak")
          lexicon
        end
        
        it "translates a gloss" do
          lexicon.lookup("pickaxe").should eq "bladvak"
        end
        
        it "maps unknown glosses to themselves" do
          lexicon.lookup("foo").should eq "foo"
        end
        
        it "warns that the gloss was not found" do
          Panglossic::Logger.any_instance.should_receive :warn
          lexicon.lookup("foo")
        end
      end
      
      context "containing multiple entries" do
        let(:input) { (<<-__LEX__) }
          bladvak: pickaxe
          gedbe  : bookstore
          yakka  :heterogeneous
        __LEX__
        
        it "translates the glosses" do
          lexicon.lookup("pickaxe").should eq "bladvak"
          lexicon.lookup("bookstore").should eq "gedbe"
          lexicon.lookup("heterogeneous").should eq "yakka"
        end
      end
      
      context "with multiple glosses per entry" do
        let(:input) { (<<-__LEX__) }
          bladvak: pickaxe; shoehorn
          gedbe  : bookstore
        __LEX__
        
        it "translates the glosses" do
          lexicon.lookup("pickaxe").should eq "bladvak"
          lexicon.lookup("shoehorn").should eq "bladvak"
          lexicon.lookup("bookstore").should eq "gedbe"
        end
      end
      
      context "with multiple entries per gloss" do
        let(:input) { (<<-__LEX__) }
          bladvak: pickaxe
          jidmar : pickaxe
        __LEX__
        
        it "prompts for clarification" do
          lexicon.should_receive(:prompt).with("pickaxe", ["bladvak", "jidmar"])
          lexicon.lookup("pickaxe")
        end
        
        context "when :prompt => false" do
          let(:lexicon_options) { {:prompt => false} }
          
          it "picks the first translation" do
            lexicon.lookup("pickaxe").should eq "bladvak"
          end
        end
      end
      
      context "when entries have long glosses" do
        let(:input) { (<<-__LEX__) }
          bladvak: thing for eating rice
          jidmar : bubble-blowing tool
          tokk: tool; grep face
          yghrax: marzipan tool
        __LEX__
        
        it "indexes words in them" do
          lexicon.lookup("thing").should eq "bladvak"
        end
        
        it "doesn't use them unless an exact match can't be found" do
          lexicon.lookup("tool").should eq "tokk"
        end
        
        it "excludes stopwords" do
          lexicon.lookup("for").should eq "for"
        end
      end
      
      context "looking up a foreign word" do
        let(:input) { (<<-__LEX__) }
          bladvak: thing for eating rice
          jidmar : bubble-blowing tool
          tokk: tool; grep face
          yghrax: marzipan tool
        __LEX__
        
        it "returns an array of glosses" do
          lexicon.reverse_lookup("tokk").should eq ["tool", "grep face"]
        end
      end
    end
  end
end
