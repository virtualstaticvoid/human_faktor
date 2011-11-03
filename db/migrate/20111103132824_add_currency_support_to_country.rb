class AddCurrencySupportToCountry < ActiveRecord::Migration
  def self.up
    change_table :countries do |t|
      t.string :currency_symbol, :length => 3
      t.string :currency_code, :length => 3
    end

    # update some known countries
    update_country('za', 'ZAR', 'R')
    update_country('us', 'USD', '$')

  end

  def self.down
    change_table :countries do |t|
      t.remove :currency_code
      t.remove :currency_symbol
    end
  end

private

  def self.update_country(iso_code, code, symbol)
    Country.find_by_iso_code(iso_code).update_attributes(
      :currency_symbol => symbol,
      :currency_code => code
    )
  end

end
