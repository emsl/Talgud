class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.string :name, :null => false                            # Talgute nimi
      t.string :code, :null => false
      t.string :url, :null => false                            # Talgu internetiaadress
      t.datetime :begins_at, :null => false                     # Toimumise algus
      t.datetime :ends_at, :null => false                       # Toimumise lõpp
      t.references :event_type, :null => false
      t.integer :manager_id, :references => :users, :null => false         # Talgujuhi id, selle kaudu leiab telefoni, e-posti. Viitab users tabelisse
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
      t.text :meta_aim_description                              # Talgute eesmärk ja hüvang
      t.text :meta_job_description                              # Talgutööd
      t.text :meta_bring_with_you                               # Kaasa võtta
      t.text :meta_provided_for_participiants                   # Talgulistele pakutav
      t.text :meta_subject_info                                 # Info talguobjekti kohta
      t.string :meta_subject_owner                              # Talguobjekti omanik
      t.string :meta_subject_protegee                           # Kas objekt on looduskaitse või muinsuskaitse all
      t.string :meta_subject_heritage_number                    # Muinsuskaitse objekti korral sisestada mäletise number

      t.datetime :deleted_at
      t.timestamps
      t.userstamps(true)
      t.references :account, :null => false
    end
    
    add_index :events, [:account_id, :deleted_at], :name => :index_events_account_deleted
  end

  def self.down
    drop_table :events
  end
end
