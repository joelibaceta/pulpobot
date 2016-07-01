module PulpoBot
  module Commands
    class Questions < SlackRubyBot::Commands::Base
      
      bot = Cleverbot.new('1d4seUHqQlPX1iTE', 'pU2ZVB0g0cRkGiFIbxVcSdczvcW87V3K')
      
      @mp_accounts = Hash.new
  
      match(/^(?<bot>\w*)\s(?<expression>.*)$/) do |client, data, match| 
        
        puts "CLIENT: #{client}   |   DATA: #{data}   |   MATCH: #{match[:expression]} \n " 
        
        expression = match[:expression] 
        
        mp_match_money_request = /cobrale (?<amount>.*) a (?<person>.*)$/.match(expression)
        mp_account_request = /el email de mercadopago de (?<person>.*) es (?<account>.*)$/.match(expression)
        wanna_joke = /(chiste)/
        
        p "MATCH MP: #{mp_account_request.inspect} \n"
        
        if mp_account_request != nil
          
          mail_match = /.*:(?<email>.*)\|/.match(mp_account_request[:account])
          
          @mp_accounts[mp_account_request[:person]] = mail_match[:email]
          
          client.say(channel: data.channel, text: ["Guardado", "Ok!", "Dale"].sample)
        
        elsif mp_match_money_request != nil 
          
          money_request       = MercadoPago::MoneyRequest.new
          money_request.currency_id   = "ARS"
          money_request.amount        = mp_match_money_request[:amount].scan(/\d/).join('').to_f 
          money_request.payer_email   = @mp_accounts[mp_match_money_request[:person]]
          money_request.description   = "PulpoBot Request"
          money_request.concept_type  = "off_platform"
          begin
            money_request.save do |response|
              
              puts " \n ============== \n"
              puts response
              puts " \n ============== \n"
              
              if response.code.to_s == "200" || response.code.to_s == "201" 
                client.say(channel: data.channel, text: "#{mp_match_money_request[:person]} pagale los #{mp_match_money_request[:amount]} aqui: #{money_request.init_point}")
              else 
                if @mp_account.nil? 
                  client.say(channel: data.channel, text: "Ok, cual es tu mail de MercadoPago?")
                else
                  error_msg = JSON.parse(response.body)["message"] rescue " "
                  client.say(channel: data.channel, text: "#{response.code} #{response.message} : #{error_msg}")
                  
                end
                
              end
            end
          rescue Exception => e
            puts " \n ============== \n"
            puts "ERROR: #{e}"
            puts " \n ============== \n"
            client.say(channel: data.channel, text: e.message)
            client.say(channel: data.channel, text: e.backtrace)
          end
            
        elsif wanna_joke
          jokes = JSON.parse(File.open(File.dirname(__FILE__) + '/jokes.json').read)
          
          client.say(channel: data.channel, text: "Ok")
          client.say(channel: data.channel, text: jokes.sample["joke"])
        else
          client.say(channel: data.channel, text: bot.say(match[:expression]))
        end
        
        
        
      end
      
    end
  end
end