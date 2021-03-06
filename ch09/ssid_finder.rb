#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   SSID scanner
# Requirements:
#   root/administrative privliges
# 
require 'socket'
include Socket::Constants

pf = Gem.win_platform? ? Socket::PF_LAT : Socket::PF_PACKET
# Open a Soccket as (very low level), (receive as a Raw), (for every packet(ETH_P_ALL))
socket = Socket.new(pf, Socket::SOCK_RAW, 0x03_00)

puts "\n\n"
puts "       BSSID       |       SSID        "  
puts "-------------------*-------------------"
while true
  # Capture the wire then convert it to hex then make it as an array
  packet = socket.recvfrom(2048)[0].unpack('H*').join.scan(/../)
  #
  # The Beacon Packet Pattern:
  # 1- The IEEE 802.11 Beacon frame starts with 0x08000000h, always!
  # 2- The Beacon frame value located at the 10th to 13th byte
  # 3- The number of bytes before SSID value is 62 bytes
  # 4- The 62th byte is the SSID length which is followed by the SSID string
  # 5- Transmitter(BSSID) or the AP MAC address which is located at 34 to 39 bytes 
  #
  if packet.size >= 62 && packet[9..12].join == "08000000"   # Make sure it's a Beacon frame
    pp "found a beacon"
    ssid_length = packet[61].hex - 1                         # Get the SSID's length
    ssid  = [packet[62..(62 + ssid_length)].join].pack('H*') # Get the SSID 
    bssid = packet[34..39].join(':').upcase                  # Get THE BSSID

    puts " #{bssid}" + "    " + "#{ssid}"
  end

end
