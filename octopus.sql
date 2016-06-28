--
-- Structure de la table `chanlist`
--

CREATE TABLE IF NOT EXISTS `chanlist` (
`id` int(11) NOT NULL,
  `chan` text NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Structure de la table `closelist`
--

CREATE TABLE IF NOT EXISTS `closelist` (
`id` int(11) NOT NULL,
  `chan` text NOT NULL,
  `reason` text NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Structure de la table `members`
--

CREATE TABLE IF NOT EXISTS `members` (
`id` int(11) NOT NULL,
  `login` text NOT NULL,
  `code` text NOT NULL,
  `level` enum('1','2','3','4','5') NOT NULL,
  `current_uid` text NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Structure de la table `online`
--

CREATE TABLE IF NOT EXISTS `online` (
`id` int(11) NOT NULL,
  `nick` text NOT NULL,
  `uid` text NOT NULL,
  `user` text NOT NULL,
  `host` text NOT NULL,
  `vhost` text NOT NULL,
  `real` text NOT NULL,
  `start` text NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;


CREATE TABLE IF NOT EXISTS `actions` (
`id` int(11) NOT NULL,
  `action` text NOT NULL,
  `args` longtext NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;


--
-- Index pour les tables exportées
--

--
-- Index pour la table `chanlist`
--
ALTER TABLE `chanlist`
 ADD PRIMARY KEY (`id`);

--
-- Index pour la table `closelist`
--
ALTER TABLE `closelist`
 ADD PRIMARY KEY (`id`);

--
-- Index pour la table `members`
--
ALTER TABLE `members`
 ADD PRIMARY KEY (`id`);

--
-- Index pour la table `online`
--
ALTER TABLE `online`
 ADD PRIMARY KEY (`id`);

--
-- Index pour la table `actions`
--
ALTER TABLE `actions`
 ADD PRIMARY KEY (`id`);
