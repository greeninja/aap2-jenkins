import org.apache.commons.httpclient.HttpClient
import org.apache.commons.httpclient.methods.GetMethod
import org.apache.http.impl.client.CloseableHttpClient
import groovy.json.JsonSlurper

def token = "<token>"
def url = "https://192.168.33.166/api/v2/inventories/"

def http = new HttpClient()
def getUrl = new GetMethod(url)
getUrl.setRequestHeader("accept","application/json")
getUrl.setRequestHeader("Authorization","Bearer ${token}")

http.executeMethod(getUrl)

def html = getUrl.getResponseBodyAsString()

def jsonSlurper = new JsonSlurper()
def invs = jsonSlurper.parseText(html)

def list = []

invs.results.each {
  def key = it.id
  def item = [(key): it.name]
  list.add(item)
}
return list