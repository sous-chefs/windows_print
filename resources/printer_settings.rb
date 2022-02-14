#
# Author:: Derek Groh (<dgroh@arch.tamu.edu>)
# Cookbook:: windows_print
# Resource:: printer_settings
#
# Copyright:: 2013, Texas A&M
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

unified_mode true

property :printer_name, String, name_property: true
property :path, String, required: true
property :file, String, required: true
# property :collate, Boolean
# property :color, Boolean
# property :computer, String
# property :duplexingmode, String # OneSided, TwoSidedLongEdge, TwoSidedShortEdge
# property :inputobject, String
# property :papersize, String # Custom, Letter, LetterSmall, Tabloid, Ledger, Legal, Statement, Executive, A3, A4, A4Small, A5, B4, B5, Folio, Quarto, Sheet10x14, Sheet11x17, Note, Envelope9, Envelope10, Envelope11, Envelope12, Envelope14, CSheet, DSheet, ESheet, EnvelopeDL, EnvelopeC5, EnvelopeC3, EnvelopeC4, EnvelopeC6, EnvelopeC65, EnvelopeB4, EnvelopeB5, EnvelopeB6, EnvelopeItaly, EnvelopeMonarch, EnvelopePersonal, FanfoldUS, FanfoldStandardGerman, FanfoldLegalGerman, ISOB4, JapanesePostcard, Sheet9x11, Sheet10x11, Sheet15x11, EnvelopeInvite, Reserved48, Reserved49, LetterExtra, LegalExtra, TabloidExtra, A4Extra, LetterTransverse, A4Transverse, LetterExtraTransverse, APlus, BPlus, LetterPlus, A4Plus, A5Transverse, B5Transverse, A3Extra, A5Extra, B5Extra, A2, A3Transverse, A3ExtraTransverse, JapaneseDoublePostcard, A6, JapaneseEnvelopeKaku2, JapaneseEnvelopeKaku3, JapaneseEnvelopeChou3, JapaneseEnvelopeChou4, LetterRotated, A3Rotated, A4Rotated, A5Rotated, B4JISRotated, B5JISRotated, JapanesePostcardRotated, JapaneseDoublePostcardRotated, A6Rotated, JapaneseEnvelopeKaku2Rotated, JapaneseEnvelopeKaku3Rotated, JapaneseEnvelopeChou3Rotated, JapaneseEnvelopeChou4Rotated, B6JIS, B6JISRotated, Sheet12x11, JapaneseEnvelopeYou4, JapaneseEnvelopeYou4Rotated, PRC16K, PRC32K, PRC32KBig, PRCEnvelope1, PRCEnvelope2, PRCEnvelope3, PRCEnvelope4, PRCEnvelope5, PRCEnvelope6, PRCEnvelope7, PRCEnvelope8, PRCEnvelope9, PRCEnvelope10, PRC16KRotated, PRC32KRotated, PRC32KBigRotated, PRCEnvelope1Rotated, PRCEnvelope2Rotated, PRCEnvelope3Rotated, PRCEnvelope4Rotated, PRCEnvelope5Rotated, PRCEnvelope6Rotated, PRCEnvelope7Rotated, PRCEnvelope8Rotated, PRCEnvelope9Rotated, PRCEnvelope10Rotated
# property :printerobject, String
# property :printerticketxml, String
property :domain_username, String
property :domain_password, String

action :restore do
  converge_by "Restore printer settings for #{new_resource.printer_name}" do
    execute 'Sanitize Network Drives' do
      command 'net use * /d /y'
    end

    if printer_exists?
      execute 'Map Network Drive' do
        command "net use z: \"#{new_resource.path}\" /user:\"#{new_resource.domain_username}\" \"#{new_resource.domain_password}\""
      end
      if file_exists?
        Chef::Log.debug("\"#{new_resource.file}\" does not exist - skipping.")
      else
        execute new_resource.printer_name do
          # not_if { File.exists?("#{new_resource.path}\\#{new_resource.file}") }
          command "RUNDLL32 PRINTUI.DLL,PrintUIEntry /Sr /n \"#{new_resource.printer_name}\" /a \"#{new_resource.path}\\#{new_resource.file}\" d u g 8 r"
        end
      end
      execute 'Unmap Network Drive' do
        command 'net use z: /d'
      end
    else
      Chef::Log.debug("\"#{new_resource.printer_name}\" printer not found - unable to restore settings.")
    end
  end
end

action :create do
  converge_by "Create printer settings for #{new_resource.printer_name}" do
    execute 'Sanitize Network Drives' do
      command 'net use * /d /y'
    end

    if printer_exists?
      execute 'Map Network Drive' do
        command "net use z: \"#{new_resource.path}\" /user:\"#{new_resource.domain_username}\" \"#{new_resource.domain_password}\""
      end

      execute "Create #{new_resource.printer_name}.bin" do
        command "RUNDLL32 PRINTUI.DLL,PrintUIEntry /Ss /n \"#{new_resource.printer_name}\" /a \"c:\\chef\\cache\\#{new_resource.file}\" d u g 8"
      end

      execute 'Upload file' do
        command "move \"c:\\chef\\cache\\#{new_resource.file}\" \"z:\\\""
      end

      execute 'Unmap Network Drive' do
        command 'net use z: /d'
      end
    else
      Chef::Log.debug("\"#{new_resource.printer_name}\" printer not found - unable to create settings.")
    end
  end
end

action_class do
  def printer_exists?
    check = powershell_out("Get-wmiobject -Class Win32_Printer -EnableAllPrivileges | where {$_.name -like '#{new_resource.printer_name}'} | fl name").run_command
    check.stdout.include?(new_resource.printer_name)
  end

  def file_exists?
    ::File.exist?("#{new_resource.path}\\#{new_resource.file}")
  end
end
