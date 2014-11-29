<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="http://bluemountain.princeton.edu/xsl/titles" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" version="2.0" exclude-result-prefixes="xs xd mods">
    <xsl:import href="mods.xsl"/>
    <xsl:output method="html"/>
    <xsl:param name="app-root"/>
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
    <xsl:template match="mods:mods">
        <xsl:variable name="iconpath" select="local:title-icon(current()/mods:identifier)"/>
        <xsl:variable name="linkpath" select="concat( 'title.html?titleURN=', current()/mods:identifier)"/>
        <div class="col-sm-6 col-md-3">
            <div class="thumbnail">
                <img class="thumbnail" src="{$iconpath}" alt="icon"/>
                <div class="caption">
                    <p>
                        <a href="{$linkpath}">
                            <span class="titleInfo">
                                <xsl:apply-templates select="mods:titleInfo[empty(@type)]"/>
                            </span>
                        </a>
                    </p>
                    <p>Lorem ipsum</p>
                </div>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>