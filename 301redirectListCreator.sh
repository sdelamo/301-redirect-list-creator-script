#!/usr/bin/env groovy
import groovy.json.JsonSlurper

def missingParameters = 3
def variables = [:]
for (a in this.args) {
	['-bingAppId=', '-output=', '-url='].each {
		if(a.startsWith(it)) {
			variables[it.substring(1,it.length()-1)] = a.substring(it.length(), a.length()) 
			missingParameters--	
		}
	}
}

if(missingParameters == 0) {
	def outputFile = new File(variables['output'])
	def url = variables['url']
	outputFile.setText('')
	def offset = 1;
	def total = 99;
	def count = 50
	def links = [] as Set
	def firstCall = true
	while(offset <= total) {
		def bingURL = 'http://api.search.live.net/json.aspx?Appid='+variables['bingAppId']+'&query=site:'+url+'&sources=Web&web.count='+count+'&web.offset='+offset
		json = new JsonSlurper().parseText( new URL( bingURL ).text )	
		if(firstCall) {
			total = json.SearchResponse.Web.Total
			firstCall = false
		}
		json.SearchResponse.Web.Results.each { value ->
			links << value.Url
		}
		offset += count
	}
	links.each {
		def path
		if(it.startsWith('http://www.') && !url.startsWith('http://www.') && url.startsWith('http://')) {
			def urlWithoutWWW = 'http://' + it.substring('http://www.'.length(), it.length())
			path = urlWithoutWWW.replace(url, '')
		} else {
			 path = it.replace(url, '')
		}
		outputFile << 'redirect 301 '+ path + ' ' + url + '\n'		
	}
} else {
	println "301redirectListCreator.sh"
	println "---------------------------"
	println "Retrieves a list of current indexed links by Bing."
	println "It creates a 301 redirection list which can be used in an .htaccess file"
	println "---------------------------"
	println "usage: 301redirectListCreator.sh [args]"
	println "every argument is required"
	println "args: "
	println "	-bingAppId=			YOUR_BING_APP_ID"
	println "	-output=			output file. The result of the script will be stored in this file"
	println "	-url=				url which we want to retrieve a list of its indexed urls by bing"
}