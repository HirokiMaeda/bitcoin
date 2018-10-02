require './method.rb'

while(1)
  current_price = get_price
  puts current_price

  buy_price = 450000
  sell_price = 500000
  size = 0.001
  if(curent_price > sell_price) && (get_my_money("BTC")["amount"] > size)
    puts "SELL"
    order("SELL", sell_price, size)
  elsif (current_price < buy_price) && (get_my_money("JPY")["amount"] > 1000)
    order("BUY", buy_price, size)
    puts "BUY"
  else
    puts "PASS "
  end
  sleep(1)
end
