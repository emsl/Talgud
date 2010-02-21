class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.string :name, :null => false                            # Talgute nimi
      t.string :code, :null => false
      t.datetime :begins_at, :null => false                     # Toimumise algus
      t.datetime :ends_at, :null => false                       # Toimumise lõpp
      t.references :event_type, :null => false
      t.integer :event_manager_id, :references => :users, :null => false         # Talgujuhi id, selle kaudu leiab telefoni, e-posti. Viitab users tabelisse
      t.string :status                                          # Talgu staatus
      
      t.string :location_address_country_code, :null => false   # Talgute toimumiskoht
      t.integer :location_address_county_id, :references => :counties
      t.integer :location_address_municipality_id, :references => :municipalities
      t.integer :location_address_settlement_id, :references => :settlements
      t.text :location_address_street
      t.decimal :latitude, :precision => 12, :scale => 10       # Koordinaadid
      t.decimal :longitude, :precision => 12, :scale => 10
      t.integer :max_participants                               # Talguliste maksimumarv
      t.text :gathering_location                                # Kogunemiskoht (paneks selle esialgu tavalise tekstiväljana)
      t.datetime :gathering_time                                # Kogunemise aeg kohas
      t.text :notes                                             # Lisainfo
      
      # Metainfo, mis võiks olla ühes väljas
      t.text :_talgu_eesmark                                    # Talgute eesmärk ja hüvang
      t.text :_talgutoode_kirjeldus                             # Talgutööd
      t.text :_kaasa_votta                                      # Kaasa võtta
      t.text :_talgulistele_pakutav                             # Talgulistele pakutav
      t.text :_info_talguobjekti_kohta                          # Info talguobjekti kohta
      t.string :_talguobjekti_omanik                            # Talguobjekti omanik
      t.string :_kas_objekt_on_kaitsealune                      # Kas objekt on looduskaitse või muinsuskaitse all
      t.string :_objekti_malestise_number                       # Muinsuskaitse objekti korral sisestada mäletise number

      t.datetime :deleted_at
      t.timestamps
      t.userstamps(true)
      t.references :account, :null => false
    end
  end

  def self.down
    drop_table :events
  end
end
