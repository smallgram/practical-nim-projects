import httpClient
import xmltree
import htmlparser
import sequtils

import nimquery

let webpage = "https://store.steampowered.com/explore/new/"

var client = newHttpClient()
var contents = client.getContent(webpage)

if contents.len > 0:
  let xml = parseHtml(contents)
  let newReleases = xml.querySelectorAll("div#tab_newreleases_content a.tab_item")
  let newReleaseNames = newReleases.map(
    proc(q:XmlNode):(string, string) =
      (q.querySelector("div.tab_item_content div.tab_item_name").innerText,
      q.querySelector("div.discount_block").attr("data-price-final"))
  )
  for r in newReleaseNames:
    echo r
  #let newReleasePrices = newReleases.map(
    #proc(q.XmlNode):string =




