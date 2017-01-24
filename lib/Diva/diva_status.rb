module Diva
class DivaStatus

	CODES = {
		1000	=>	["DIVA_OK","The function completes normally."],
		1001	=> 	["DIVA_ERR_UNKNOWN", "An unknown status has been received from the DIVArchive WS."],
		1002	=>	["DIVA_ERR_INTERNAL", "An internal error has been detected by the DIVArchive System."],
		1003	=>	["DIVA_ERR_NO_ARCHIVE_SYSTEM", "There are no DIVArchive Systems available."],
		1004	=>	["DIVA_ERR_BROKEN_CONNECTION","The connection between the DIVArchive System and DIVArchive WS has been broken."],
		1005	=>	["DIVA_ERR_DISCONNECTING", "Client is in the process of disconnecting with the DIVArchive System."],
		1006	=> 	["DIVA_ERR_ALREADY_CONNECTED", "The Client is attempting to create multiple sessions for a single application"],
		1007	=>	["DIVA_ERR_WRONG_VERSION","The Client is trying to connect the DIVArchive WS to the DIVArchive System using the wrong version"],
		1008	=>	["DIVA_ERR_INVALID_PARAMETER","A parameter value has not been understood by the DIVArchive System."],
		1009	=>	["DIVA_ERR_OBJECT_DOESNT_EXIST","The specified object does not exist in the DIVArchive Database and is not being archived."],
		1010	=>	["DIVA_ERR_SEVERAL_OBJECTS","More than one Object with the specified name exists in the DIVArchive Database"],
		1011	=>	["DIVA_ERR_NO_SUCH_REQUEST","requestNumber identifies no Request."],
		1012	=>	["DIVA_ERR_NOT_CANCELABLE","The Request specified for cancelation is not able to be cancelled."],
		1013	=>	["DIVA_ERR_SYSTEM_IDLE","The DIVArchive System is no longer able to accept connections and queries."],
		1014	=>	["DIVA_ERR_WRONG_LIST_SIZE","The maxListSize parameter is too big (greater than 500), or to small (less than 1)."],
		1015	=>	["DIVA_ERR_LIST_NOT_INITIALIZED","The DIVA_initObjectsList() function has not been called first."],
		1016	=>	["DIVA_ERR_OBJECT_ALREADY_EXISTS","An object with the Name and Category already exists in the DIVArchive System."],
		1017	=>	["DIVA_ERR_GROUP_DOESNT_EXIST","The Group or the Array of Disks does not exist."],
		1018	=>	["DIVA_ERR_SOURCE_OR_DESTINATION_DOESN’T_EXIST","The specified Source/Destination is not known by the DIVArchive System."],
		1019	=>	["DIVA_WARN_NO_MORE_OBJECTS","The end of the list has been reached during the call (see Description)."],
		1020	=>	["DIVA_ERR_NOT_CONNECTED","No open connection."],
		1021	=>	["DIVA_ERR_GROUP_ALREADY_EXISTS","The specified Group already exists."],
		1022	=>	["DIVA_ERR_GROUP_IN_USE","he Group contains at least one Object Instance."],
		1023	=>	["DIVA_ERR_OBJECT_OFFLINE","There is no inserted Instance in the Library and no Actor could provide a Disk Instance."],
		1024	=>	["DIVA_ERR_TIMEOUT","Time out limit has been reached before communication between the DIVArchive System and DIVArchive WS could be performed. Time out duration is set by the DIVARCHIVE_RESPONSE_TIMEOUT _IN_MINUTES variable and equals 10 minutes by default."],
		1025	=>	["DIVA_ERR_LAST_INSTANCE","deleteObject must be used to delete the last Instance of an Object."],
		1026	=>	["DIVA_ERR_PATH_DESTINATION","The specified path does not exist on the Destination DIVArchive System."],
		1027	=>	["DIVA_ERR_INSTANCE_DOESNT_EXIST","Instance specified for restoring this Object does not exist."],		
		1028	=>	["DIVA_ERR_INSTANCE_OFFLINE","Instance specified for restoring this Object is ejected, or the Actor owning the specified Disk Instance is not available."],
		1029	=>	["DIVA_ERR_INSTANCE_MUST_BE_ON_TAPE","The specified Instance is not a Tape Instance."],
		1030	=>	["DIVA_ERR_NO_INSTANCE_TAPE_EXIST","No Tape Instance exists for this Object."],		
		1031	=>	["DIVA_ERR_OBJECT_IN_USE","The specified object is currently being read or deleted."],		
		1032	=>	["DIVA_ERR_CANNOT_ACCEPT_MORE_REQUESTS","Count of simultaneous requests reached the maximum allowed value. This variable is set in the conf.properties configuration file. The default is 300."],	
		1033	=>	["DIVA_ERR_TAPE_DOESNT_EXIST","There is no Tape associated with the given barcode."],
		1034	=>	["DIVA_ERR_INVALID_INSTANCE_TYPE","Cannot Partially Restore this type of Instance."],
		1035	=>	["DIVA_ERR_ACCESS_DENIED","Permissions are not sufficient enough to perform the requested operation or the object is currently in use."],
		1036	=>	["DIVA_ERR_OBJECT_PARTIALLY_DELETED","The specified Object has Instances that are partially deleted."],
		1038	=>	["DIVA_ERR_COMPONENT_NOT_FOUND","The specified component could not be found."],
		1039	=>	["DIVA_ERR_OBJECT_IS_LOCKED","The specified object is locked and in use by another process (refer to Section 2.11.30)."],

	}

	REQUEST = {
			3 => "DIVA_COMPLETED",
		    4 => "DIVA_ABORTED",
		    5 => "DIVA_CANCELLED",
		    6 => "DIVA_UNKNOWN_STATE",
		    11 => "DIVA_PARTIALLY_ABORTED",
		    12 => "DIVA_RUNNING"		
	}

	REQUEST_TYPES = {
		0=>"DIVA_ARCHIVE_REQUEST",
		1=>"DIVA_RESTORE_REQUEST",
		2=>"DIVA_DELETE_REQUEST",
		3=>"DIVA_EJECT_REQUEST",
		4=>"DIVA_INSERT_REQUEST",
		5=>"DIVA_COPY_REQUEST",
		6=>"DIVA_COPY_TO_NEW_REQUEST",
		7=>"DIVA_RESTORE_INSTANCE_REQUEST",
		8=>"DIVA_DELETE_INSTANCE_REQUEST",
		9=>"DIVA_UNKNOW_REQUEST_TYPE",
		10=>"DIVA_AUTOMATIC_REPACK_REQUEST",
		11=>"DIVA_ONDEMAND_RAPACK_REQUEST",
		12=>"DIVA_ASSOC_COPY_REQUEST",
		13=>"DIVA_PARTIAL_RESTORE_REQUEST",
		14=>"DIVA_MULTIPLE_RESTORE_REQUEST",
		15=>"DIVA_TRANSCODE_ARCHIVED_REQUEST",
		16=>"DIVA_EXPORT_REQUEST",
		17=>"DIVA_TRANSFER_REQUEST",
		18=>"DIVA_AUTOMATIC_VERIFY_TAPES_REQUEST",
		19=>"DIVA_MANUAL_VERIFY_TAPES_REQUEST",
	}

	def self.explain(code)
		return CODES[code][0]
	end

	def self.details(code)
		return CODES[code][1]
	end
end

end