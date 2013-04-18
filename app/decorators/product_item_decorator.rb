class ProductItemDecorator < Draper::Decorator
  decorates_association :product
  delegate_all

  def price
    h.number_to_currency(source.price).delete("CN")
  end

  def total
    h.number_to_currency(source.total).delete("CN")
  end

  # def renminbi(m)
  #   m = format("%.2f",m).to_f.to_s
  #   left = ""
  #   if m.to_s[0] == "-"
  #     m = m[1,m.length]
  #     left = "-"
  #   end
  #   a = m.split(".")
  #   l = a[0].reverse()
  #   r = a[1]
  #   t = ""
  #   i = 0
  #   l.length.times do
  #     t += l[i] + ((i + 1) % 3 == 0 && (i + 1) != l.length ? "," : "")
  #     i+=1
  #   end
  #   left + t.reverse() + "." + r
  # end

end