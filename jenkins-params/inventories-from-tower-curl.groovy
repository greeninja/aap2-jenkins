import groovy.json.JsonSlurper

def out = new ByteArrayOutputStream()
def err = new ByteArrayOutputStream()

def token = "cFsdexwJ2H4xHf343pBKaRNRWRKupz"
def url = "https://192.168.33.166/api/v2/inventories/"
def cmd = ["bash", "-c", "curl -s -k ${url} --header 'Authorization: Bearer ${token}' --header 'Content-Type: application/json'"]

def proc = cmd.execute()

proc.consumeProcessOutput(out, err)
proc.waitForOrKill(1000)

def jsonSlurper = new JsonSlurper()
def invs = jsonSlurper.parseText(out.toString())

def list = []

invs.results.each {
  def key = it.id
  def item = [(key): it.name]
  list.add(item)
}

return list
