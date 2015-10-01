require 'spec_helper'

describe WhiplashApi::ShipnoticeItem do

  before(:all) do
    @notice = WhiplashApi::Shipnotice.create sender: "Some Name", eta: "2016-01-01 03:00", warehouse_id: 1
  end

  before(:each) do
    @item   = WhiplashApi::Item.create sku: "SOME-SKU-KEY", title: "Some Title"
    @valid_attributes = {shipnotice_id: @notice.id, item_id: @item.id, quantity: 1}
  end

  def test_shipnotice_items
    described_class.all params: { shipnotice_id: @notice.id }
  end

  describe ".create" do
    it "creates shipnotice item with given attributes" do
      snitem = described_class.create @valid_attributes
      expect(snitem).to be_persisted
      expect(test_shipnotice_items).to include(snitem)
    end

    xit "does not create shipnotice item without required fields" do
      @valid_attributes.each_pair do |field, value|
        snitem = described_class.create @valid_attributes.merge(field => nil)
        expect(snitem).not_to be_persisted
        expect(test_shipnotice_items).not_to include(snitem)
      end
    end
  end

  describe ".all" do
    it "lists all the items for the given Shipment notice" do
      snitem = described_class.create @valid_attributes
      expect(test_shipnotice_items).to include(snitem)
    end

    xit "allows filtering of listing using parameters" do
      snitem = described_class.create @valid_attributes
      expect(described_class.all(params: {shipnotice_id: @notice.id, since_id: snitem.id}).count).to eq 0
      described_class.create @valid_attributes
      expect(described_class.all(params: {shipnotice_id: @notice.id, since_id: snitem.id}).count).to eq 1
    end
  end

  describe ".find" do
    it "can find a Shipnotice Item using its ID" do
      snitem = described_class.create @valid_attributes
      expect(described_class.find(snitem.id)).to eq snitem
    end
  end

  describe ".update" do
    it "updates the shipnotice item with the given ID" do
      snitem = described_class.create @valid_attributes
      described_class.update(snitem.id, quantity: 2)
      expect(snitem.reload.quantity).to eq 2
    end

    it "raises error if no shipnotice item was found with the given ID" do
      expect {
        described_class.update(999999, quantity: 2)
      }.to raise_error(WhiplashApi::RecordNotFound).with_message("No shipnotice item found with given ID.")
    end

    # FIXME: docs state wrong code/name for this status
    it "raises error when updating shipnotice item for a shipnotice which has been processed" do
      snitem = described_class.create @valid_attributes
      allow_any_instance_of(WhiplashApi::Shipnotice).to receive(:status).and_return(250)
      expect {
        described_class.update(snitem.id, quantity: 2)
      }.to raise_error(WhiplashApi::Error).with_message("You can only update shipnotice items for unprocessed shipnotices.")
    end
  end

  describe ".delete" do
    it "deletes the shipnotice item with the given ID" do
      snitem = described_class.create @valid_attributes
      expect(test_shipnotice_items).to include(snitem)
      described_class.delete(snitem.id)
      expect(test_shipnotice_items).not_to include(snitem)
    end

    it "raises error when trying to delete a shipnotice item for a shipnotice which has already been processed" do
      snitem = described_class.create @valid_attributes
      allow_any_instance_of(WhiplashApi::Shipnotice).to receive(:status).and_return(250)
      expect {
        described_class.delete(snitem.id)
      }.to raise_error(WhiplashApi::Error).with_message("You can not delete shipnotice items for shipnotices which have already been processed.")
    end
  end
end