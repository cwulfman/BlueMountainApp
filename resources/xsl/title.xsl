<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:local="http://bluemountain.princeton.edu/xsl/titles" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0" exclude-result-prefixes="xs xd">
    <xsl:import href="mods.xsl"/>
    <xsl:import href="tei.xsl"/>
    <xsl:output method="html"/>
    <xsl:param name="app-root"/>
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
    <xsl:template match="tei:TEI">
        <xsl:choose>
            <xsl:when test="$context = 'selected-title-label'">
                <span class="titleInfo">
                    <xsl:apply-templates select="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblStruct/tei:monogr/tei:title[@level='j']"/>
                </span>
            </xsl:when>
            <xsl:when test="$context = 'selected-title-label-brief'">
                <span class="titleInfo">
                    <xsl:apply-templates select="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblStruct/tei:monogr/tei:title[@level='j']" mode="brief"/>
                </span>
            </xsl:when>
            <xsl:when test="$context='selected-title-abstract'">
                <span class="caption">
                    <xsl:apply-templates select="tei:text/tei:body"/>
                </span>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:title">
        <xsl:if test="tei:seg[@type='nonSort']">
            <xsl:apply-templates select="tei:seg[@type='nonSort']"/>
            <xsl:text>&#160;</xsl:text>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="tei:seg[@type='sub']">
                <xsl:value-of select="concat(tei:seg[@type='main'], ': ', xs:string(tei:seg[@type='sub']))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="tei:seg[@type='main']"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:title" mode="brief">
        <xsl:if test="tei:seg[@type='nonSort']">
            <xsl:apply-templates select="tei:seg[@type='nonSort']"/>
            <xsl:text>&#160;</xsl:text>
        </xsl:if>
        <xsl:value-of select="tei:seg[@type='main']"/>
    </xsl:template>
    <xsl:template match="tei:p">
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
</xsl:stylesheet>