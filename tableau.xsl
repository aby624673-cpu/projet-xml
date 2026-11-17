<?xml version="1.0" encoding="UTF-8"?>
<!-- ISEP26-XXX — NOM Prénom -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="html" encoding="UTF-8" indent="yes"
              doctype-system="about:legacy-compat"/>

  <!-- ÉTAPE 5 : le seuil d'admission, modifiable en UN seul endroit -->
  <xsl:param name="seuil" select="10"/>

  <!-- ÉTAPE 8 : clé de regroupement des étudiants par classe (méthode de Muenchian) -->
  <xsl:key name="par-classe" match="etudiant" use="@classe"/>

  <!-- ÉTAPE 4 : la page HTML complète -->
  <xsl:template match="/promotion">
    <html lang="fr">
      <head>
        <meta charset="UTF-8"/>
        <title>Promotion <xsl:value-of select="@filiere"/></title>
        <link rel="stylesheet" href="style.css"/>
      </head>
      <body>
        <header>
          <h1>Promotion <xsl:value-of select="@filiere"/></h1>
          <p>Année <xsl:value-of select="@annee"/></p>
        </header>

        <main>
          <!-- ÉTAPE 7 : les quatre chiffres clés, tous calculés par XPath -->
          <div class="stats">
            <div class="carte">
              <span class="valeur"><xsl:value-of select="count(etudiant)"/></span>
              <span class="legende">étudiants</span>
            </div>
            <div class="carte">
              <span class="valeur">
                <xsl:value-of select="count(etudiant[sum(notes/note) div count(notes/note) &gt;= $seuil])"/>
              </span>
              <span class="legende">admis (moyenne ≥ <xsl:value-of select="$seuil"/>)</span>
            </div>
            <div class="carte">
              <span class="valeur">
                <xsl:value-of select="format-number(sum(etudiant/notes/note[@matiere='XML']) div count(etudiant), '0.00')"/>
              </span>
              <span class="legende">moyenne en XML</span>
            </div>
            <div class="carte">
              <span class="valeur"><xsl:value-of select="count(etudiant[not(email)])"/></span>
              <span class="legende">emails manquants</span>
            </div>
          </div>

          <!-- ÉTAPE 8 : un <h2> + un tableau par classe.
               On ne garde que le PREMIER étudiant de chaque classe pour
               récupérer la liste des classes sans doublon. -->
          <xsl:for-each select="etudiant[generate-id() = generate-id(key('par-classe', @classe)[1])]">
            <xsl:variable name="nb" select="count(key('par-classe', @classe))"/>

            <h2>
              Classe <xsl:value-of select="@classe"/>
              (<xsl:value-of select="$nb"/>
              <xsl:choose>
                <xsl:when test="$nb &gt; 1"> étudiants</xsl:when>
                <xsl:otherwise> étudiant</xsl:otherwise>
              </xsl:choose>)
            </h2>

            <table>
              <thead>
                <tr>
                  <th>Rang</th>
                  <th>Matricule</th>
                  <th>Nom</th>
                  <th>Prénom</th>
                  <th>Classe</th>
                  <th>Email</th>
                  <th>Moyenne</th>
                  <th>Résultat</th>
                </tr>
              </thead>
              <tbody>
                <!-- ÉTAPE 6 : tri numérique décroissant ; position() est calculé
                     APRÈS le tri, donc le rang recommence à 1 dans chaque classe -->
                <xsl:apply-templates select="key('par-classe', @classe)">
                  <xsl:sort select="sum(notes/note) div count(notes/note)"
                            data-type="number" order="descending"/>
                </xsl:apply-templates>
              </tbody>
            </table>
          </xsl:for-each>
        </main>

        <footer>Page générée par XSLT à partir de etudiants.xml</footer>
      </body>
    </html>
  </xsl:template>

  <!-- Une ligne du tableau -->
  <xsl:template match="etudiant">
    <xsl:variable name="moyenne" select="sum(notes/note) div count(notes/note)"/>
    <tr>
      <!-- ÉTAPE 9 : classe « major » sur la 1re ligne de chaque tableau.
           xsl:attribute DOIT venir avant tout élément enfant de <tr>. -->
      <xsl:if test="position() = 1">
        <xsl:attribute name="class">major</xsl:attribute>
      </xsl:if>

      <td class="rang"><xsl:value-of select="position()"/></td>
      <td><xsl:value-of select="@matricule"/></td>
      <td><xsl:value-of select="nom"/></td>
      <td><xsl:value-of select="prenom"/></td>
      <td><xsl:value-of select="@classe"/></td>

      <!-- ÉTAPE 5 : email absent -->
      <td>
        <xsl:choose>
          <xsl:when test="email"><xsl:value-of select="email"/></xsl:when>
          <xsl:otherwise><span class="absent">non renseigné</span></xsl:otherwise>
        </xsl:choose>
      </td>

      <td class="moyenne"><xsl:value-of select="format-number($moyenne, '0.00')"/></td>

      <!-- ÉTAPE 5 : résultat conditionnel -->
      <td>
        <xsl:choose>
          <xsl:when test="$moyenne &gt;= $seuil">
            <span class="badge reussite">Admis</span>
          </xsl:when>
          <xsl:otherwise>
            <span class="badge echec">À revoir</span>
          </xsl:otherwise>
        </xsl:choose>
      </td>
    </tr>
  </xsl:template>

</xsl:stylesheet>
