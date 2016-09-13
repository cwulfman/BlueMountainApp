<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" version="2.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs xd">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Nov 5, 2015</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> cwulfman</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:div[@type='Paragraph']">
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    <xsl:template match="tei:div">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:lb">
        <br/>
    </xsl:template>
    <xsl:template match="title-foo"><!-- This shouldn't work: no namespace! -->
        <xsl:choose>
            <xsl:when test="seg[@type='sub']">
                <xsl:value-of select="concat(seg[@type='main'], ': ', xs:string(seg[@type='sub']))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="seg[@type='main']"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>