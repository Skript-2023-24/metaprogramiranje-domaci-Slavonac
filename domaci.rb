require "google_drive"

session = GoogleDrive::Session.from_config("config.json")
ss = session.spreadsheet_by_key("1BKxBHq8-dY88RFFZzTfq_a7aRQvGw1-3lN7DT79SUxQ")

class Tabela
    include Enumerable

    def initialize(lista)
        @lista = lista
    end
    def dajListu
        @lista
    end
    def ispisiTabelu
        matrica = []
        @lista.each do |kljuc, vrednost|
            lista = [kljuc] + vrednost
            matrica.push lista
        end
        p matrica.transpose
    end

    def each
        @lista.each do |kljuc, vrednost|
            yield kljuc
            @lista[kljuc].each do |element|
                yield element if element != "Prazno"
            end
        end
    end

    def [](imeKolone)
        return @lista[imeKolone]
    end

    def []=(imeKolone, indeks, vrednost)
        @lista[imeKolone][indeks] = vrednost
        return @lista[imeKolone][indeks]
    end
  
    def row (brojReda)
        if brojReda == 1
            @lista.keys
        else
            red = []
            @lista.each do |kljuc, vrednost|
                red.push vrednost[brojReda - 2]
            end
        return red
        end
    end
  
    def method_missing(imeFunkcije, *args)
        @lista.keys.each do |kljuc, vrednost|
            if imeFunkcije.to_s.downcase == kljuc.gsub(" ", "").downcase
                return @lista[kljuc]
            end
        end
        indeks = -1
        @lista.each do |kljuc, vrednost|
            indeks = @lista[kljuc].index(imeFunkcije.to_s) if @lista[kljuc].include? imeFunkcije.to_s
        end
        if indeks != -1 
            red = []
            @lista.each do |kljuc, vrednost|
                red.push vrednost[indeks]
            end
            return red
        end
    end

    def +(drugaTabela)
        if @lista.keys == drugaTabela.dajListu.keys
            @lista.each do |kljuc, vrednost|
                @lista[kljuc] += drugaTabela.dajListu[kljuc]
            end
        else p "Zaglavlja se ne poklapaju"
        end
    end

    def -(drugaTabela)
        if @lista.keys == drugaTabela.dajListu.keys
            @lista.each do |kljuc, vrednost|
                @lista[kljuc] -= drugaTabela.dajListu[kljuc]
            end
        else p "Zaglavlja se ne poklapaju"
        end
    end
end

sveTabele = {}
brojacObjekta = 1

ss.worksheets.each do |ws|
    brojac = 0
    zaglavlje = {}
    ws.rows.each do |red|
        if !red.all? {|el| el.empty?}
            brojac += 1
            break if brojac > 1
            red.each_with_index do |el, indeks|
                zaglavlje[indeks] = el if el != ""
            end
        end
    end
    tabelaSaKolonama = {}

    zaglavlje.each do |kljuc, vrednost|
        tabelaSaKolonama[vrednost] = []
        ws.rows.each do |red|
            tabelaSaKolonama[vrednost].push red[kljuc] if red[kljuc] != "" && red[kljuc] != "total" && red[kljuc] != "subtotal" && red[kljuc] != vrednost
            tabelaSaKolonama[vrednost].push "Prazno" if red[kljuc] == "" && tabelaSaKolonama[vrednost].size > 0
        end
    end

    oznaka = "t#{brojacObjekta}"
    sveTabele[oznaka] = Tabela.new(tabelaSaKolonama)
    brojacObjekta += 1
end


t1 = sveTabele["t1"]
t2 = sveTabele["t2"]

class Array
   def avg
    ukupno = 0
    velicina = 0
    each do |vrednost| 
        if vrednost.to_i != 0
            ukupno += vrednost.to_i 
            velicina += 1
        end
    end
    ukupno.to_f / velicina
   end
   def sum
    ukupno = 0
    each { |vrednost| ukupno += vrednost.to_i if vrednost.to_i != 0}
   end
end
=begin
t1.ispisiTabelu

p t1.row(2)

t1.each do |celija|
    p celija
end

p t1["Prva kolona"]
t1["Prva kolona"][2] = 3

p t1.prvaKolona
p t1.prvaKolona.sum
p t1.drugaKolona.avg
p t1.indeks

p t1.prvakolona.map {|celija| celija + 100}
p t1.drugakolona.reduce(:+)
p t1.trecaKolona.select {|broj| broj < 5}

p t1.dajListu
t1 - t2
p t1.dajListu

p t1.dajListu
t1 + t2
p t1.dajListu

=end