<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:mets="http://www.loc.gov/mets" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="http://bmtnfoo" version="2.0" exclude-result-prefixes="xs mods mets">
    <xsl:output method="html"/>
    <xsl:param name="app-root"/>
    <xsl:param name="context"/>
    <xsl:param name="veridianLink"/>
    <xsl:param name="titleURN"/>
    <xsl:param name="issueURN"/>
    <xsl:function name="local:urn-to-veridian-bmtnid">
        <xsl:param name="urn"/>
        <xsl:value-of select="substring-after($urn, 'urn:PUL:bluemountain:')"/>
    </xsl:function>
    <xsl:function name="local:title-icon">
        <xsl:param name="titleURN"/>
        <xsl:variable name="bmtnid" select="substring-after($titleURN, 'urn:PUL:bluemountain:')"/>
        <xsl:value-of select="concat('/exist/rest', $app-root, '/resources/icons/periodicals/', $bmtnid, '/large.jpg')"/>
    </xsl:function>
    <xsl:function name="local:veridian-url-from-bmtnid">
        <xsl:param name="issueURN"/>
        <xsl:variable name="bmtnid" select="local:urn-to-veridian-bmtnid($issueURN)"/>
        <xsl:variable name="protocol" as="xs:string">http://</xsl:variable>
        <xsl:variable name="host" as="xs:string">bluemountain.princeton.edu</xsl:variable>
        <xsl:variable name="servicePath" as="xs:string">bluemtn</xsl:variable>
        <xsl:variable name="scriptPath" as="xs:string">cgi-bin/bluemtn</xsl:variable>
        <xsl:variable name="a" as="xs:string">d</xsl:variable>
        <xsl:variable name="e" as="xs:string">-------en-20--1--txt-IN-----</xsl:variable>
        <xsl:variable name="args" as="xs:string" select="concat('?a=',$a,'&amp;d=',$bmtnid,'&amp;e=',$e)"/>
        <xsl:value-of select="concat($protocol, $host, '/', $servicePath, '/', $scriptPath, $args)"/>
    </xsl:function>
    <xsl:template name="title-string">
        <xsl:param name="modsrec"/>
        <span class="titleInfo">
            <xsl:apply-templates select="$modsrec/mods:titleInfo[not(@type='uniform')][1]"/>
        </span>
    </xsl:template>
    <xsl:template name="issue-label-string">
        <xsl:param name="modsrec"/>
        <span class="issueLabel">
            <xsl:apply-templates select="$modsrec/mods:part"/>
            <xsl:text> </xsl:text>
            <xsl:apply-templates select="$modsrec/mods:originInfo"/>
        </span>
    </xsl:template>
    <xsl:template name="title-thumbnail">
        <xsl:param name="modsrec"/>
        <xsl:variable name="iconpath" select="local:title-icon($modsrec/mods:identifier)"/>
        <xsl:variable name="linkpath" select="concat($app-root, '/title.html?titleURN=', $modsrec/mods:identifier)"/>
        <div class="col-sm-6 col-md-3">
            <div class="thumbnail">
                <img class="thumbnail" src="{$iconpath}" alt="icon"/>
                <div class="caption">
                    <p>
                        <a href="{$linkpath}">
                            <span class="titleInfo">
                                <xsl:apply-templates select="$modsrec/mods:titleInfo[empty(@type)]"/>
                            </span>
                        </a>
                    </p>
                    <p>Lorem ipsum</p>
                </div>
            </div>
        </div>
    </xsl:template>
    <xsl:template match="mods:mods">
        <xsl:choose>
            <xsl:when test="$context = 'title-listing'">
                <xsl:call-template name="title-thumbnail">
                    <xsl:with-param name="modsrec" select="current()"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$context = 'selected-title-label'">
                <xsl:call-template name="title-string">
                    <xsl:with-param name="modsrec" select="current()"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$context = 'selected-issue-label'">
                <xsl:call-template name="title-string">
                    <xsl:with-param name="modsrec" select="current()"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$context = 'issue-listing-label'">
                <xsl:call-template name="issue-label-string">
                    <xsl:with-param name="modsrec" select="current()"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <i>
                    <xsl:apply-templates select="mods:titleInfo[not(@type='uniform')]"/>
                </i>
                <xsl:text>, </xsl:text>
                <xsl:apply-templates select="mods:part[@type='issue']"/>
                <xsl:text> (</xsl:text>
                <xsl:apply-templates select="mods:originInfo"/>
                <xsl:text>)</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>