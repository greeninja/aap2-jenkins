import org.apache.commons.httpclient.*
import org.apache.commons.httpclient.methods.GetMethod

def url = "https://s3.greeninja.co.uk/rpms"

def httpClient = new HttpClient()
def getUrl = new GetMethod(url)

httpClient.executeMethod(getUrl)
def html = getUrl.getResponseBodyAsString()

def s3contents = new XmlParser().parseText(html)
assert s3contents instanceof groovy.util.Node

def list = []

s3contents.Contents.each {
  list.add(it.Key.text())
}

return list