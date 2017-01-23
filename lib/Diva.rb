require "Diva/version"
require "Diva/diva_status"
require 'recursive-open-struct'

module Diva
#HTTPI.adapter = :net_http

class DivaArchive
	require 'rubygems'
	require 'savon'
	require 'nokogiri'
	require "active_support/all"

	attr_reader :session_id, :client, :archive_system, :session_timestamp, :job

	def initialize(job=nil, session_id=nil,session_timestamp=nil)
		@job=job
		@client = Savon::Client.new do
		    wsdl "http://192.168.50.70:9763/services/DIVArchiveWS_SOAP_1.0?wsdl"
		    env_namespace :soapenv
		    namespace_identifier :xsd
		    namespace "http://interaction.api.ws.diva.fpdigital.com/xsd"
		    soap_version 2
		    convert_request_keys_to :lower_camelcase 
		    element_form_default :qualified
		    raise_errors false
		    log true
			pretty_print_xml true
		end

		if(session_id==nil || session_timestamp==nil)
			puts "new session"
			registerClient
		else
			time=Time.parse(session_timestamp)
			puts "use #{session_id} time passed: #{(Time.now - time)/60} "
			@session_id =session_id
			@session_timestamp = time
		end

	end


	def registerClient()


		response = @client.call(:register_client, message: {'appName': "MaM", 'locName': "MaM_diva", 'process_id': rand(1000)})

		if response.success?
			@session_id = response.to_array(:register_client_response,:return)
			@session_timestamp=Time.now
			puts @session_timestamp

		elsif response.soap_fault?
			puts "response soap_fault"
		elsif response.http_error? 
			puts "response http_error"
		end

	end

	def getArchiveSystemInfo(options=nil)
		self.renew_registration?

		response = @client.call(:get_archive_system_info, message: {'sessionCode': @session_id, 'options': ''})

		if response.success?
			#doc  = Nokogiri::XML response.body.to_xml
			#puts doc 
			#puts response.body
			@archive_system = Nokogiri::XML(response.body.to_xml)  

	    elsif response.soap_fault?
	 	
			puts "#{response}"
		else
			puts "#{response}"
		end


	end 


	def archiveObject()

		self.renew_registration?

		objectName = "test"+rand(80).to_s
		objectCategory = "playout" 
		source = "ISILON_migrazione"
		mediaName = "GRID"
		filesPathRoot = "\\\\192.168.54.224\\MigrazioneArchivio\\RestoreDiva"
		fileNamesList = "test.mxf"
		qualityOfService = 3
		priorityLevel = 77
		comments = "Ruby webservices archive"

		response = @client.call(:archive_object,
			
			message: {

				'sessionCode': @session_id,
				'objectName': objectName,
				'objectCategory': objectCategory,
				'source': source,
				'mediaName': mediaName,
				'filesPathRoot': filesPathRoot,
				'fileNamesList': fileNamesList,
				'qualityOfService': qualityOfService,
				'priorityLevel': priorityLevel,
				'comments': comments,
				'archiveOptions': ""

			})


		if response.success?

			res = RecursiveOpenStruct.new(response.body)
			if(res.archive_object_response.return.diva_status=="1000")
				request_number=res.archive_object_response.return.request_number
				"requestNumber: #{request_number}"
				return request_number
			else
				"#{res.archive_object_response.return.diva_status}"
			end

	    elsif response.soap_fault?
	 	
			puts "#{response}"
		else
			puts "#{response}"
		end


	end 


	def get_request_info(request)
		self.renew_registration?
		response = @client.call(:get_request_info,
			
			message: {

				'sessionCode': @session_id,
				'requestNumber': request,

			})


		if response.success?

			puts response.body

			res = RecursiveOpenStruct.new(response.body)
			if(res.get_request_info_response.return.diva_status=="1000")
				puts "#{res.get_request_info_response.return.diva_request_info}"
			end
			#	"requestNumber: #{res.archive_object_response.return.request_number}"
			#else
			#	"#{res.archive_object_response.return.diva_status}"
			#end
			#doc  = Nokogiri::XML response.body.to_xml
			#puts doc 
			#puts response.body
			#@archive_system = Nokogiri::XML(response.body.to_xml)  

	    elsif response.soap_fault?
	 	
			puts "#{response}"
		else
			puts "#{response}"
		end


	end



	def renew_registration?
		
		if(((Time.now-@session_timestamp)/60 > 28) || @session_id==nil)
			puts "new registration request"
			registerClient()
		else
			puts "using #{@session_id}"
			return false
		end
	end

end #End class DivaArchive

end
