environments {
	production {
		//log4j = {
		//		debug   'grails.app'
		//}
		cb.port = 4455
		daweb3.logo = "DANRW-Logo_small.png"
		// To integrate a customized css-file, please change file name accordingly 
		main.css = "main.css"
		mobile.css = "mobile.css"
		// same as listed in CB config.properties
		localNode.id = 1
		localNode.userAreaRootPath = "/ci/storage/UserArea"
		localNode.ingestAreaRootPath = "/ci/storage/IngestArea"
		transferNode.downloadLinkPrefix = "https://localhost/transfer"
		fedora.urlPrefix = "https://localhost:8080/fedora/objects/"
		cb.presServer= "HOSTPRES"
		dataSource {
			pooled = true
			driverClassName = "org.postgresql.Driver"
			dialect = org.hibernate.dialect.PostgreSQLDialect
			dbCreate = "validate"
			url = "jdbc:postgresql://localhost:5432/CB?autoReconnect=true"
			username = "cb_usr"
			password = "4kj8yne/hx7g6D2EhjMlrg=="
			passwordEncryptionCodec = "de.uzk.hki.da.utils.DESCodec"
			characterEncoding = "UTF-8"
		
	      properties {
                        maxActive = 50
                        maxIdle = 25
                        minIdle = 1
                        initialSize = 1
                        numTestsPerEvictionRun = 3
                        maxWait = 10000
                        testOnBorrow = true
                        testWhileIdle = true
                        testOnReturn = true
                        validationQuery = "select now()"
                        minEvictableIdleTimeMillis = 1000 * 60 * 5
                        timeBetweenEvictionRunsMillis = 1000 * 60 * 5
                        }
	
		}
	}
}
