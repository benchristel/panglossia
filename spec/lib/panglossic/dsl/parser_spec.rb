require 'spec_helper'

describe Panglossic::Gloss::Parser do
  ## Token helpers
  
  def t_var(data)
    Panglossic::Gloss::Token::Variable.new(data)
  end
  
  def t_func(data)
    Panglossic::Gloss::Token::Function.new(data)
  end
  
  def t_lparen
    Panglossic::Gloss::Token::LParen.new
  end
  
  def t_rparen
    Panglossic::Gloss::Token::RParen.new
  end
  
  def t_dot
    Panglossic::Gloss::Token::Dot.new
  end

  describe '.parse' do
    let(:tokens) { [t_var("foo")] }
    let(:parse_tree) { Panglossic::Gloss::Parser.parse tokens }
    subject { parse_tree }
    
    it { should be_a Panglossic::Gloss::Expression::Root }
    its(:children) { should have(1).item }
    its(:first_child) { should be_a Panglossic::Gloss::Expression::Variable }
    its(:first_child) { should have_data "foo" }
    
    context "with a parenthesized function" do
      let(:tokens) do
        [ t_func("foo"), t_lparen, t_var("bar"), t_rparen ]
      end
      
      subject { parse_tree.first_child }
      
      it { should be_a Panglossic::Gloss::Expression::Function }
      it { should have_data "foo" }
      its(:children) { should have(1).item }
      its(:first_child) { should be_a Panglossic::Gloss::Expression::Variable }
      its(:first_child) { should have_data "bar" }
      
      context "with multiple arguments" do
        let(:tokens) do
          [ t_func("foo"), t_lparen, t_var("bar"), t_var("ziff"), t_rparen ]
        end

        its(:children) { should have(2).items }
        its(:first_child) { should be_a Panglossic::Gloss::Expression::Variable }
        its(:first_child) { should have_data "bar" }
        its(:last_child)  { should be_a Panglossic::Gloss::Expression::Variable }
        its(:last_child)  { should have_data "ziff" }
      end
    end
    
    context "with a dotted function" do
      let(:tokens) { [ t_var("foo"), t_dot, t_func("bar") ] }
    end
    
    context "with a dotted and parenthesized function" do
      let(:tokens) { [ t_var("foo"), t_dot, t_func("bar"), t_lparen, t_var("ziff"), t_rparen ] }
      
      it { should have_data "bar" }
      its(:children) { should have(2).items }
      its(:first_child) { should be_a Panglossic::Gloss::Expression::Variable }
      its(:first_child) { should have_data "foo" }
      its(:last_child)  { should be_a Panglossic::Gloss::Expression::Variable }
      its(:last_child)  { should have_data "ziff" }
      
      context "with multiple arguments" do
        let(:tokens) do
          [ t_var("kludge"), t_func("foo"), t_lparen, t_var("bar"), t_var("ziff"), t_rparen ]
        end
        
        it { should have_data "foo" }
        its(:children) { should have(3).items }
        its(:first_child) { should be_a Panglossic::Gloss::Expression::Variable }
        its(:first_child) { should have_data "kludge" }
        its(:last_child)  { should be_a Panglossic::Gloss::Expression::Variable }
        its(:last_child)  { should have_data "ziff" }
      end
    end
  end
end
