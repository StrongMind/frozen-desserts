require 'rails_helper'

RSpec.describe "toppings/edit", type: :view do
  let(:topping) {
    dessert = Dessert.create!(name: "MyDessert")
    Topping.create!(
      name: "MyString",
      dessert: dessert
    )
  }

  before(:each) do
    assign(:topping, topping)
  end

  it "renders the edit topping form" do
    render

    assert_select "form[action=?][method=?]", topping_path(topping), "post" do

      assert_select "input[name=?]", "topping[name]"

      assert_select "input[name=?]", "topping[dessert_id]"
    end
  end
end
