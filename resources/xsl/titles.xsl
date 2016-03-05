<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:bmtn-mods="http://bluemountain.princeton.edu/mods" xmlns:local="http://bluemountain.princeton.edu/xsl/titles" version="2.0" exclude-result-prefixes="xs xd mods">
    <xsl:import href="mods.xsl"/>
    <xsl:output method="html"/>
    <xsl:param name="app-root"/>
    <xsl:param name="veridianLink"/>
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Nov 29, 2014</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> cwulfman</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    <xsl:function name="local:title-icon">
        <xsl:param name="titleURN"/>
        <xsl:variable name="bmtnid" select="substring-after($titleURN, 'urn:PUL:bluemountain:')"/>
        <xsl:value-of select="concat('/exist/rest', $app-root, '/resources/icons/periodicals/', $bmtnid, '/large.jpg')"/>
    </xsl:function>
    <xsl:template match="mods:mods-old">
        <xsl:variable name="iconpath" select="local:title-icon(current()/mods:identifier[@type = 'bmtn'])"/>
        <xsl:variable name="linkpath" select="concat('title.html?titleURN=', current()/mods:identifier[@type = 'bmtn'])"/>
        <li>
            <a href="{$linkpath}">
                <img class="img-thumbnail" src="{$iconpath}" alt="icon"/>
            </a>
        </li>
    </xsl:template>
    <xsl:template match="mods:mods">
        <xsl:variable name="iconpath" select="local:title-icon(current()/mods:identifier[@type = 'bmtn'])"/>
        <xsl:variable name="linkpath" select="concat('title.html?titleURN=', current()/mods:identifier[@type = 'bmtn'])"/>
        <xsl:variable name="title">
            <xsl:choose>
                <xsl:when test="mods:titleInfo[@usage='primary']">
                    <xsl:value-of select="xs:string(mods:titleInfo[@usage='primary']/mods:title[1])"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="xs:string(mods:titleInfo[1]/mods:title[1])"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <tr>
            <td class="title-icon">
                <a href="{$linkpath}" class="title-list-icon">
                    <img class="img-thumbnail title-list" src="{$iconpath}" alt="icon"/>
                </a>
            </td>
            <td class="title-abstract">
                <p>
                    <xsl:value-of select="xs:string(mods:abstract)"/>
                </p>
            </td>
            <td class="title-issuance">
                <xsl:value-of select="mods:originInfo/mods:dateIssued[1]"/>
            </td>
        </tr>
    </xsl:template>
</xsl:stylesheet>