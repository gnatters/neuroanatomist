require 'spec_helper'

describe "nodes/show" do
  before(:each) do
    @node = assign(:node, stub_model(Node,
      :title => "Title",
      :introduction => "Introduction"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Title/)
    rendered.should match(/Introduction/)
  end
end
