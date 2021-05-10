import httpClient
import xmltree
import htmlparser
import sequtils
import strutils
import json
import std/jsonutils

import nimquery


proc getNewReleases():JsonNode =
  let webpage = "https://store.steampowered.com/explore/new/"

  var client = newHttpClient()
  var contents = client.getContent(webpage)

  if contents.len > 0:
    let xml = parseHtml(contents)
    # find all of the "new releases" tab items
    let newReleases = xml.querySelectorAll("div#tab_newreleases_content " & 
      "a.tab_item")
    # for each "new releases" item, pull out its name and price
    let newReleaseData = newReleases.map(
      proc(q:XmlNode): tuple[name: string,
                             currentPrice: string,
                             originalPrice: string,
                             platforms: seq[string],
                             tags: seq[string],
                             link: string,
                             imageLink: string] =
        
        # get platforms
        let platforms = q
          .querySelectorAll("div.tab_item_content " &
                            "div.tab_item_details " &
                            "span.platform_img")
          .map(proc(q:XmlNode):string = q.attr("class").split()[1])

        # get tags
        let tags = q
          .querySelectorAll("div.tab_item_content " &
                            "div.tab_item_details " &
                            "div.tab_item_top_tags " &
                            "span.top_tag")
          .map(proc(q:XmlNode):string = q.innerText.replace(",", "").strip())

        # get name
        let name = q
          .querySelector("div.tab_item_content div.tab_item_name")
          .innerText

        # get current price
        let currentPrice = q
          .querySelector("div.discount_block")
          .attr("data-price-final")

        # get original price
        let originalPriceNode = q
          .querySelector("div.discount_block " &
                         "div.discount_prices " &
                         "div.discount_original_price")
        let originalPrice = 
          if not originalPriceNode.isNil:
            originalPriceNode.innerText.multiReplace(("$",""),(".",""))
          else:
            currentPrice

        let link = q.attr("href")

        let imageLink = q
          .querySelector("div.tab_item_cap img.tab_item_cap_img")
          .attr("src")

        # create return tuple with (name, price, platforms, tags)
        return (name: name,
                currentPrice: currentPrice,
                originalPrice: originalPrice,
                platforms: platforms,
                tags: tags,
                link: link,
                imageLink: imageLink)
    )

    return newReleaseData.toJson


if isMainModule:
  echo getNewReleases().pretty(2)
