<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:local="http://bluemountain.princeton.edu/xsl/issue" version="2.0" exclude-result-prefixes="xs xd tei">
    <xsl:import href="tei.xsl"/>
    <xsl:output method="html"/>
    <xsl:param name="context"/>
    <xsl:param name="veridianLink"/>
    <xsl:param name="titleURN"/>
    <xsl:param name="issueURN"/>
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Nov 29, 2014</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> cwulfman</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    <xsl:template match="tei:title-simple">
        <span class="titleInfo">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="tei:title">
        <span class="titleInfo">
            <xsl:if test="tei:seg[@type = 'nonSort']">
                <xsl:variable name="nonSort">
                    <xsl:apply-templates select="tei:seg[@type = 'nonSort']"/>
                </xsl:variable>
                <xsl:value-of select="concat($nonSort, ' ')"/>
            </xsl:if>
            <xsl:apply-templates select="tei:seg[@type = 'main']"/>
            <xsl:if test="tei:seg[@type = 'sub']">
                <xsl:variable name="sub">
                    <xsl:apply-templates select="tei:seg[@type = 'sub']"/>
                </xsl:variable>
                <xsl:value-of select="concat(': ', $sub)"/>
            </xsl:if>
        </span>
    </xsl:template>
    <xsl:template match="tei:relatedItem[@type = 'constituent']">
        <tr>
            <td>
                <a href="contribution.html?issueid={$issueURN}&amp;constid={@xml:id}">
                    <xsl:apply-templates select="tei:biblStruct/tei:analytic/tei:title"/>
                </a>
            </td>
            <td>
                <xsl:for-each select="tei:biblStruct/tei:analytic/tei:respStmt/tei:persName">
                    <span class="persName">
                        <xsl:choose>
                            <xsl:when test="current()/@ref">
                                <a href="contributions.html?titleURN={$titleURN}&amp;authid={@ref}">
                                    <xsl:apply-templates select="current()"/>
                                </a>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates select="current()"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </span>
                    <xsl:if test="position() != last()">; </xsl:if>
                </xsl:for-each>
            </td>
            <td>
                <xsl:apply-templates select="tei:biblStruct/tei:monogr/tei:imprint/tei:classCode[@scheme='CCS']"/>
            </td>
        </tr>
    </xsl:template>
</xsl:stylesheet>