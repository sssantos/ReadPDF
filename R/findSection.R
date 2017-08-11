library(XML)
library(ReadPDF)


#
#
# Find lines that 
#  have a larger font than others on the page
#  shorter than most in the same column
#  have a larger font than most text nodes in the column
#  larger vertical distance between it and the next line
#

# Includes names
#    "LatestDocs/PDF/0629421650/Padula-2002-Andes virus and first case report1.xml"
# also doesn't get the subheadings for Patient 1 and Patient 2
#

findSectionHeaders =
    #
    # Given a node, find the node identifying the section in the paper
    # for this node.
    #
    #  Looking for text on its own line,  in bold or larger font.
    #  "../LatestDocs/PDF/2157652992/Calisher-2006-Bats_ Important Reservoir Hosts.xml"
    #  ""../LatestDocs/PDF/0000708828/Li-2009-Sensitive, qualitative detection of hu.xml"
    #  "../LatestDocs/PDF/2636860725/Růžek-2010-Omsk haemorrhagic fever.xml"
    #  "../LatestDocs/PDF/3757461900/Matsuzaki-2002-Antigenic and genetic characte1.xml"
    #
function(doc, sectionName = c('introduction', 'conclusions', 'results', 'methods', 'references', 'acknowledgements'))
{
    if(is.character(doc))
       doc = readPDFXML(doc)

    filter = paste(sprintf("lower-case(normalize-space(.)) = '%s'", sectionName), collapse = " or ")
    xp = sprintf("//text[%s]", filter)
    intro = getNodeSet(doc, xp)


    hasNum = FALSE
    if(!length(intro)) {
              # Find section titles with numbers    
        filter = paste(sprintf("(contains(lower-case(normalize-space(.)), '%s') and isNum(normalize-space(.)))", sectionName), collapse = " or ")
        xp = sprintf("//text[%s]", filter)
        intro = getNodeSet(lm, xp, xpathFuns = list(isNum = isSectionNum))
        hasNum = length(intro)
    }
    
    #    cols = getColPositions(doc[[1]])

    # Check if these are centered on a column or on the page. If so,
    # other nodes we think are titles also better be centered.

    if(length(intro)) {
        if(hasNum)
           return(getNodeSet(doc, "//text[isNum(string(.))]", xpathFuns = list(isNum = isSectionNum)))
        
        fontID = xmlGetAttr(intro[[1]], "font")
         # Check on line by itself and not just a word.        
        return(getNodesWithFont(doc, fontID = fontID))
    }
}

isSectionNum =
    #
    # For use in XPath test.
    #
function(x)    
   grepl("^[0-9](\\.[0-9](\\.[0-9])?)?\\. ", x)    


getNodesWithFont =
function(doc, fontID)
{
  getNodeSet(doc, sprintf("//text[@font = '%s']", fontID))        
}

isOnLineBySelf =
function(node, pos = getColPositions(doc),
         textNodes = getNodeSet(xmlParent(node), ".//text"),
         bbox = getBBox2(textNodes, TRUE))
    # doc = as(node, "XMLInternalDocument"),
{
    colNodes = getTextByCols(pageOf(node, TRUE), asNodes = TRUE)
    # determine which column this is in
    colNum = which(sapply(colNodes, function(x) any(sapply(x, identical, node))))
    col = colNodes[[colNum]]
#    lines = split(col, as.integer(sapply(col, xmlGetAttr, "top")))
    h = as.integer(xmlGetAttr(node, "top"))
    npos = as.integer(sapply(col, xmlGetAttr, "top"))
    sum(npos == h) == 1
}

#XXX give proper name.
f = 
function(page, nodes = getNodeSet(page, ".//text"), bb = getBBox2(nodes, TRUE),
          cols = getColPositions(page))
{    
    b = split(bb, cut(bb$left, c(0, cols[-1], Inf) -2))
    k = lapply(b, function(x) x[order(x$top),])
}