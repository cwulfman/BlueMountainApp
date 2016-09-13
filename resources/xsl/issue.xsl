<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:local="http://bluemountain.princeton.edu/xsl/titles" version="2.0" exclude-result-prefixes="xs xd tei">
    <xsl:import href="tei.xsl"/>
    <xsl:output method="html"/>
    <xsl:param name="context"/>
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Nov 29, 2014</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> cwulfman</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    <xsl:template match="tei:title">
        <span class="titleInfo">
            <xsl:apply-templates/>
        </span>
    </xsl:template><!--    <xsl:template match="tei:TEI">
        <span class="titleInfo">
            <xsl:apply-templates select="./tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblStruct/tei:monogr/tei:title" />
        </span>
    </xsl:template>-->
</xsl:stylesheet>