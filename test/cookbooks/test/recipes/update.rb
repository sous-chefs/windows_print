# frozen_string_literal: true

windows_print_printer 'Kitchen Office [1] & %LITERAL_ENV%' do
  driver_name 'Generic / Text Only'
  ports 'Kitchen TCP [1]' => '192.0.2.20'
  share_name ''
  location 'Updated room'
  comment 'Updated comment'
end
