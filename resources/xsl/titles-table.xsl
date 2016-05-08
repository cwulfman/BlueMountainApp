<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs xd" version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> May 8, 2016</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> cwulfman</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml" indent="yes" doctype-system="about:legacy-compat"/>
    <xsl:template match="TEI">
        <xsl:apply-templates select="teiHeader/fileDesc/sourceDesc/biblStruct/monogr"/>
    </xsl:template>
    <xsl:template match="monogr">
        <tr>
            <td>
                <xsl:apply-templates select="title[@level='j']"/>
            </td>
            <td>
                <xsl:apply-templates select="imprint/date"/>
            </td>
        </tr>
    </xsl:template>
    <xsl:template match="title">
        <xsl:choose>
            <xsl:when test="seg[@type='sub']">
                <xsl:value-of select="concat(seg[@type='main'], ': ', xs:string(seg[@type='sub']))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="seg[@type='main']"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="date">
        <xsl:value-of select="string-join((@from, @to), '-')"/>
    </xsl:template>
</xsl:stylesheet>