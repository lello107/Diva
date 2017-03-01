require "Diva/version"
require "Diva/diva_status"
require 'recursive-open-struct'
require "awesome_print"

module Diva
#HTTPI.adapter = :net_http

class DivaArchive
	require 'rubygems'
	require 'savon'
	require 'nokogiri'
	require "active_support/all"

	attr_reader :session_id, :client, :archive_system, :session_timestamp, :job, :register

	def initialize(job=nil, session_id=nil,session_timestamp=nil, register=nil)
		@job=job
		@register = register==nil ? "MaM" : register
		@client = Savon::Client.new do
		    wsdl "http://192.168.50.70:9763/services/DIVArchiveWS_SOAP_1.0?wsdl"
		    env_namespace :soapenv
		    namespace_identifier :xsd
		    namespace "http://interaction.api.ws.diva.fpdigital.com/xsd"
		    soap_version 1
		    convert_request_keys_to :lower_camelcase 
		    element_form_default :qualified
		    raise_errors false
		    log true
			pretty_print_xml true
		end


		@session_info =  File.join( File.dirname(__FILE__), '../session.yml' )
		diva_session = open(@session_info) {|f| YAML.load(f) }
		@session_id = diva_session["session_id"]
		@session_timestamp = diva_session["session_timestamp"]

		if(@session_timestamp==nil || @session_id==nil)
			registerClient
		end

		# if(session_id==nil || session_timestamp==nil)
		# 	puts "new session"
		# 	registerClient
		# else
		# 	time=Time.parse(session_timestamp)
		# 	puts "use #{session_id} time passed: #{(Time.now - time)/60} "
		# 	@session_id =session_id
		# 	@session_timestamp = time
		# end

	end


	def read_yaml
		diva_session = open(@session_info) {|f| YAML.load(f) }
		return diva_session
	end

	def registerClient()


		response = @client.call(:register_client, message: {'appName': @register, 'locName': "#{@register}_diva", 'process_id': rand(1000)})

		if response.success?
			@session_id = response.to_array(:register_client_response,:return)[0]
			@session_timestamp=Time.now
			puts @session_timestamp

			begin
				diva = {"session_id"=>@session_id,"session_timestamp"=>@session_timestamp}
				#root_path = Rails.root == nil ? "" : Rails.root
				
				File.open(@session_info,"w") {|f| YAML.dump(diva,f)}
			rescue Exception=>ex
				puts "#{Time.now} error: #{ex}"
				#session_info = "log/session.yml"
				#File.open(session_info,"w") {|f| YAML.dump(diva,f)}
			else
				puts "file written!"
			end

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
			return response.body
	    elsif response.soap_fault?
	 	
			return "#{response}"
		else
			return "#{response}"
		end


	end 

	def restoreObject(*args)
		self.renew_registration?

		sessionCode = @session_id
		objectName = args[0][:objectName]
		objectCategory  = args[0][:objectCategory] == nil ? 'playout' : args[0][:objectCategory]
		destination = args[0][:destination] == nil ? 'ISILON_migrazione' : args[0][:destination]
		filesPathRoot  = args[0][:filesPathRoot]  == nil ? '\\\\192.168.54.224\\MigrazioneArchivio\\RestoreDiva' : args[0][:filesPathRoot]
		qualityOfService  = args[0][:qualityOfService] == nil ? 0 : args[0][:qualityOfService]
		priorityLevel  = args[0][:priorityLevel] == nil ? 50 : args[0][:priorityLevel]
		
		message = {
			'sessionCode': sessionCode,
			'objectName': objectName,
			'objectCategory': objectCategory,
			'destination': destination,
			'filesPathRoot': filesPathRoot,
			'qualityOfService': qualityOfService,
			'priorityLevel': priorityLevel,
			'restoreOptions': ''		
		}
		 
		ap message
		response = @client.call(:restore_object, message: message)
			
		#destination,filesPathRoot,qualityOfService,priorityLevel,restoreOptions

		if response.success?
			res = RecursiveOpenStruct.new(response.body)
			if(res.restore_object_response.return.diva_status=="1000")
				ap res
				return res.restore_object_response.return.request_number
			else
				return false
			end
		else
			return false
		end		

	end

	def to_diva_hash(message)
    	builder = Builder::XmlMarkup.new
    	#builder.instruct!(:xml, encoding: "UTF-8")
    	builder.tag!("soapenv:Envelope xmlns:soapenv='http://schemas.xmlsoap.org/soap/envelope/' xmlns:xsd='http://interaction.api.ws.diva.fpdigital.com/xsd' xmlns:xsd1='http://model.api.ws.diva.fpdigital.com/xsd'") do 
	    	builder.soapenv :Header
	    	builder.tag!('soapenv:Body') do 
		    	builder.tag!('xsd:multipleRestoreObject') do 
		    		builder.xsd :sessionCode, message[:sessionCode]
		    		builder.xsd :objectName, message[:objectName]
		    		builder.xsd :objectCategory, message[:objectCategory]


			    	message[:destinations].each do |dest|
					    builder.tag!('xsd:destinations') { |b|
					      b.xsd1 :destination, dest[:destination]
					      b.xsd1 :filePathRoot, dest[:filePathRoot]
					    }
					end

					builder.xsd :qualityOfService, message[:qualityOfService]
					builder.xsd :priorityLevel, message[:priorityLevel]
					builder.xsd :restoreOptions, message[:restoreOptions]
				end #end request
			end #end body
		end #end envelop
		
    	return builder.target!
  end

	def multipleRestoreObject(*args)
		self.renew_registration?

		sessionCode = @session_id
		objectName = args[0][:objectName]
		objectCategory  = args[0][:objectCategory] == nil ? 'playout' : args[0][:objectCategory]
		
		filesPathRoot  = args[0][:filesPathRoot]  == nil ? '\\\\192.168.54.224\\MigrazioneArchivio\\RestoreDiva' : args[0][:filesPathRoot]
		qualityOfService  = args[0][:qualityOfService] == nil ? 0 : args[0][:qualityOfService]
		priorityLevel  = args[0][:priorityLevel] == nil ? 50 : args[0][:priorityLevel]
		
		destinations = args[0][:destinations] == nil ? {destination: 'ISILON_migrazione', filePathRoot: filesPathRoot} : args[0][:destinations]

		message = {
			'sessionCode': sessionCode,
			'objectName': objectName,
			'objectCategory': objectCategory,
			'destinations': destinations,
			#'filesPathRoot': filesPathRoot,
			'qualityOfService': qualityOfService,
			'priorityLevel': priorityLevel,
			'restoreOptions': ''		
		}
		 

		ap message
		
		new_message = self.to_diva_hash(message) 

		ap new_message
		response = @client.call(:multiple_restore_object, xml: new_message)
		#response = @client.call(:multiple_restore_object) do |soap|
		#	ap "SOAP: #{soap}"
		#	ap body
			#soap.body = to_diva_hash(message)
		#end
		#destination,filesPathRoot,qualityOfService,priorityLevel,restoreOptions

		if response.success?
			res = RecursiveOpenStruct.new(response.body)
			if(res.multiple_restore_object_response.return.diva_status=="1000")
				ap res
				return res.multiple_restore_object_response.return.request_number
			else
				return false
			end
		else
			return false
		end		

	end

	def getObjectInfo(objectName,objectCategory)
		self.renew_registration?

		response = @client.call(:get_object_info,	
			message: {

				'sessionCode': @session_id,
				'objectName': objectName,
				'objectCategory': objectCategory,

			})

		#ap message
		
		if response.success?
			res = RecursiveOpenStruct.new(response.body)
			if(res.get_object_info_response.return.diva_status=="1000")
				ap res.get_object_info_response.return.info
				return res.get_object_info_response.return.info
			else
				ap res.get_object_info_response.return.info
				return res.get_object_info_response.return.info				
			end
		else
			return false
		end		

	end

	def archiveObject(objectName,objectCategory)

		self.renew_registration?

		objectName = objectName
		#objectCategory = "playout" 
		source = "ISILON_migrazione"
		mediaName = "GRID"
		filesPathRoot = "\\\\192.168.54.224\\MigrazioneArchivio\\RestoreDiva"
		fileNamesList = objectName + ".mxf"
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
				return res.archive_object_response.return.diva_status, request_number

			else
				request_number=res.archive_object_response.return.request_number
				return res.archive_object_response.return.diva_status, request_number
			end

	    elsif response.soap_fault?
	 	
			puts "#{response}"
			#raise 
		else
			puts "#{response}"
		end


	end 

	def cancelRequest(request)
		self.renew_registration?
		usage = "missing arg! exp cancelRequest(27009)"

		ap usage; return false if request == nil or request.class == "Hash"

		message = {
			'sessionCode': @session_id,
			'requestNumber': request,
		}

		ap message

		response = @client.call(:cancel_request, message: message)

		if response.success?
			puts response.body
			res = RecursiveOpenStruct.new(response.body)
			if(res.cancel_request_response.return.diva_status=="1000")
				return Diva::DivaStatus::CODES[1000]
			else
				return Diva::DivaStatus::CODES[res.cancel_request_response.return.diva_status.to_i]
			end
		else
			return false
		end


	end


	## get_request_info ##
	#
	#
	## in: request (diva request number)
	## out: status, abort_code, progress, info
	##
	##
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
				
				status = Diva::DivaStatus::REQUEST[(res.get_request_info_response.return.diva_request_info.request_state).to_i]
				abort_code= res.get_request_info_response.return.diva_request_info.abortion_reason.code
				progress = res.get_request_info_response.return.diva_request_info.progress
				info = res.get_request_info_response.return.diva_request_info.abortion_reason.description
				object_summary = res.get_request_info_response.return.diva_request_info.object_summary
				request_type = res.get_request_info_response.return.diva_request_info.request_type
				current_priority = res.get_request_info_response.return.diva_request_info.current_priority

				result={status: status, abort_code: abort_code, progress: progress, info: info, object_summary: object_summary, request_type: Diva::DivaStatus::REQUEST_TYPES[request_type.to_i],current_priority: current_priority}

				return result
				
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
