# DaliCount 0.8.1-beta

DaliCount est un compteur de combat léger pour **World of Warcraft: Forever 1.60.1**, développé par **Daliranas**.

## Fonctions

- Degats totaux
- DPS
- Soins totaux
- HPS
- Absorptions
- Degats subis
- Degats evitables
- Interruptions
- Dissipations
- Morts
- Vue Combat courant / Session globale
- Details par sort apres le combat
- Détails compacts ajustés automatiquement au nombre de sorts
- Partage du classement vers Groupe, Dire ou Raid (hors combat)
- Interface sombre inspirée de WoW, avec bordures dorées et couleurs de classe
- Icône de spécialisation et repère du joueur local
- Fenêtre déplaçable, redimensionnable par échelle et verrouillable
- Redimensionnement direct avec la poignée en bas à droite
- Fond semi-transparent avec opacité réglable
- 5 a 15 lignes affichables
- Hauteur automatique selon le nombre de participants (désactivable)
- Aucun framework externe (Ace3, LibStub, etc.)

## Important : API WoW Forever

WoW Forever utilise l'API moderne `C_DamageMeter`. Les anciennes methodes de Recount/Details basees sur `COMBAT_LOG_EVENT_UNFILTERED` ne sont pas la bonne approche ici.

Pendant le combat, plusieurs valeurs de `C_DamageMeter` sont des **secret values**. DaliCount ne fait ni calcul, ni tri Lua, ni comparaison sur ces valeurs. Il conserve l'ordre fourni par Blizzard et envoie directement les valeurs aux widgets natifs (barres et textes). Les détails par sort sont ouverts hors combat. Les éléments décoratifs utilisent uniquement des textures fournies par le client WoW.

## Installation

1. Fermer WoW.
2. Copier le dossier `DaliCount` dans :
   `World of Warcraft/_classic_beta_/Interface/AddOns/`
3. Verifier que le chemin final est :
   `.../Interface/AddOns/DaliCount/DaliCount.toc`
4. Relancer WoW puis activer DaliCount dans la liste des addons.
5. Taper `/dc` pour afficher/masquer la fenetre.

## Commandes

- `/dc` : afficher/masquer
- `/dc mode` : mode suivant
- `/dc mode dps`
- `/dc mode damage`
- `/dc mode healing`
- `/dc mode hps`
- `/dc mode absorbs`
- `/dc mode interrupts`
- `/dc mode dispels`
- `/dc mode taken`
- `/dc mode avoidable`
- `/dc mode deaths`
- `/dc combat` : combat courant
- `/dc session` : session globale
- `/dc reset` : reset du meter
- `/dc lock` / `/dc unlock`
- `/dc rows 1-15`
- `/dc auto on|off` : activer ou désactiver la hauteur automatique
- `/dc scale 75-150` : taille de l'interface en pourcentage
- `/dc opacity 10-100` : transparence du fond
- `/dc report groupe 5` : partager les 5 premières lignes au groupe
- `/dc report dire 5`
- `/dc report raid 5`

Le canal Dire est protégé par WoW : DaliCount prépare le rapport dans la zone de discussion, puis le joueur confirme l'envoi avec Entrée.
- `/dc position` : réinitialiser la position et l'échelle
- `/dc version` : afficher la version et le développeur
- `/dc help`

## Note beta : SavedVariables

Les builds beta WoW Forever 1.60.1 ont eu un bug de chargement des `SavedVariables` lors d'un redemarrage complet du client. Si la position ou les reglages se reinitialisent, cela peut venir du client et non de DaliCount.

## Etat

Cette version est une premiere beta technique. Le point le plus important est de tester sur un vrai combat Forever :

- rendu live des secret values ;
- ordre DPS/HPS ;
- detail par sort apres combat ;
- reset ;
- changement Combat / Session.

Si le client remonte une erreur Lua, activer `/console scriptErrors 1`, reproduire le probleme et conserver le texte complet de l'erreur.
