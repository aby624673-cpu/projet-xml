<?xml version="1.0" encoding="UTF-8"?>
<!-- ISEP26-XXX — NOM Prénom -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="html" encoding="UTF-8" indent="yes"/>

  <!-- Règle de la racine : on construit la liste <ul> -->
  <xsl:template match="/promotion">
    <ul>
      <xsl:apply-templates select="etudiant"/>
    </ul>
  </xsl:template>

  <!-- Règle d'un étudiant : un <li> au format « Prénom Nom » -->
  <xsl:template match="etudiant">
    <li>
      <xsl:value-of select="prenom"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="nom"/>
    </li>
  </xsl:template>

</xsl:stylesheet>
