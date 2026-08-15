class TeamCareerProfile {
  const TeamCareerProfile({
    required this.history,
    required this.firstEntry,
    required this.championships,
    required this.wins,
    required this.podiums,
    required this.achievements,
  });

  final String history;
  final int firstEntry;
  final int championships;
  final int wins;
  final int podiums;
  final List<String> achievements;
}

class DriverCareerProfile {
  const DriverCareerProfile({
    required this.summary,
    required this.achievements,
  });

  final String summary;
  final List<String> achievements;
}

const careerDataUpdated = '18 Jul 2026';

const teamCareerData = <String, TeamCareerProfile>{
  'mclaren': TeamCareerProfile(
    history:
        'Founded by Bruce McLaren, the team entered Formula 1 in 1966 and became one of the sport’s defining constructors. Its champions include Emerson Fittipaldi, James Hunt, Niki Lauda, Alain Prost, Ayrton Senna, Mika Hakkinen, Lewis Hamilton and Lando Norris.',
    firstEntry: 1966,
    championships: 10,
    wins: 203,
    podiums: 448,
    achievements: [
      'Won consecutive Constructors’ Championships in 2024 and 2025.',
      'Delivered Lando Norris’ first Drivers’ Championship in 2025.',
      'Produced dominant title eras with Prost and Senna, then Hakkinen.',
    ],
  ),
  'mercedes': TeamCareerProfile(
    history:
        'Mercedes first raced as a works team in the 1950s and returned with a modern factory squad in 2010. The Silver Arrows became the benchmark of the turbo-hybrid era under Toto Wolff.',
    firstEntry: 1954,
    championships: 8,
    wins: 129,
    podiums: 210,
    achievements: [
      'Won a record eight consecutive Constructors’ titles from 2014 to 2021.',
      'Powered Lewis Hamilton to six of his seven Drivers’ Championships.',
      'Set new standards for sustained success in the hybrid era.',
    ],
  ),
  'redbull': TeamCareerProfile(
    history:
        'Red Bull bought Jaguar Racing in 2004 and debuted under its own name in 2005. The team rose rapidly under Christian Horner and Adrian Newey, first with Sebastian Vettel and later Max Verstappen.',
    firstEntry: 2005,
    championships: 6,
    wins: 130,
    podiums: 235,
    achievements: [
      'Won four consecutive title doubles with Sebastian Vettel from 2010 to 2013.',
      'Won Constructors’ titles in 2022 and 2023 during the Verstappen era.',
      'Set a team record of 21 wins from 22 Grands Prix in 2023.',
    ],
  ),
  'ferrari': TeamCareerProfile(
    history:
        'Scuderia Ferrari is the only constructor to have competed in every Formula 1 World Championship season since 1950. Its history spans champions from Alberto Ascari and Niki Lauda to Michael Schumacher and Kimi Raikkonen.',
    firstEntry: 1950,
    championships: 16,
    wins: 251,
    podiums: 646,
    achievements: [
      'Most successful constructor in Formula 1 history.',
      'Won six consecutive Constructors’ titles from 1999 to 2004.',
      'Michael Schumacher delivered five consecutive Drivers’ titles from 2000 to 2004.',
    ],
  ),
  'williams': TeamCareerProfile(
    history:
        'Frank Williams and Patrick Head established Williams Grand Prix Engineering in 1977. The team grew into a dominant force of the 1980s and 1990s and developed champions including Alan Jones, Nigel Mansell, Alain Prost, Damon Hill and Jacques Villeneuve.',
    firstEntry: 1978,
    championships: 9,
    wins: 114,
    podiums: 245,
    achievements: [
      'Won nine Constructors’ and seven Drivers’ Championships.',
      'Claimed five Constructors’ titles between 1992 and 1997.',
      'Returned to the podium with Carlos Sainz during the 2025 rebuild.',
    ],
  ),
  'racingbulls': TeamCareerProfile(
    history:
        'The Faenza squad traces its lineage to Minardi in 1985. Red Bull acquired the team and renamed it Toro Rosso for 2006; it later raced as AlphaTauri, RB and Racing Bulls while continuing to develop young talent.',
    firstEntry: 1985,
    championships: 0,
    wins: 2,
    podiums: 6,
    achievements: [
      'Sebastian Vettel scored the team’s first win at Monza in 2008.',
      'Pierre Gasly delivered a second Monza victory in 2020.',
      'Developed future champions and race winners through the Red Bull programme.',
    ],
  ),
  'astonmartin': TeamCareerProfile(
    history:
        'Aston Martin first appeared in Formula 1 in 1959–60 and returned as a works identity in 2021. The present Silverstone operation descends from Jordan, which entered in 1991, followed by Midland, Spyker, Force India and Racing Point.',
    firstEntry: 1959,
    championships: 0,
    wins: 1,
    podiums: 12,
    achievements: [
      'Fernando Alonso scored eight podiums in Aston Martin’s breakthrough 2023 season.',
      'Built a new Silverstone technology campus for its works-team ambitions.',
      'Began an exclusive Honda works power-unit partnership in 2026.',
    ],
  ),
  'audi': TeamCareerProfile(
    history:
        'Audi entered Formula 1 as a full works constructor in 2026 after acquiring Sauber. The programme combines Audi power-unit development in Germany with the long-established Hinwil chassis operation in Switzerland.',
    firstEntry: 2026,
    championships: 0,
    wins: 0,
    podiums: 0,
    achievements: [
      'Became a full works Formula 1 constructor and power-unit manufacturer in 2026.',
      'Scored its first World Championship points during its debut campaign.',
      'Built on Sauber’s F1 presence dating back to 1993.',
    ],
  ),
  'cadillac': TeamCareerProfile(
    history:
        'Cadillac joined the grid as Formula 1’s 11th team in 2026. Backed by General Motors and TWG Motorsports, the new American constructor established operations in the United States and the United Kingdom.',
    firstEntry: 2026,
    championships: 0,
    wins: 0,
    podiums: 0,
    achievements: [
      'Joined Formula 1 as an all-new constructor for the 2026 regulations era.',
      'Signed Grand Prix winners Valtteri Bottas and Sergio Perez for its debut season.',
      'Established a long-term path toward becoming a works power-unit team.',
    ],
  ),
  'alpine': TeamCareerProfile(
    history:
        'Alpine is the current identity of Renault’s Enstone-based Formula 1 operation. The wider lineage includes Toleman, Benetton, Renault and Lotus, with the Alpine name introduced in 2021.',
    firstEntry: 1986,
    championships: 2,
    wins: 21,
    podiums: 61,
    achievements: [
      'Renault won consecutive title doubles with Fernando Alonso in 2005 and 2006.',
      'Esteban Ocon delivered Alpine’s first victory at Hungary in 2021.',
      'Scored a double podium at the rain-hit 2024 Sao Paulo Grand Prix.',
    ],
  ),
  'haas': TeamCareerProfile(
    history:
        'Gene Haas founded the first American-led Formula 1 team in three decades. Haas debuted in 2016 with Ferrari power and operates across bases in the United States, the United Kingdom and Italy.',
    firstEntry: 2016,
    championships: 0,
    wins: 0,
    podiums: 0,
    achievements: [
      'Finished sixth on debut with Romain Grosjean at the 2016 Australian Grand Prix.',
      'Achieved a best Constructors’ Championship finish of fifth in 2018.',
      'Kevin Magnussen earned the team’s first pole position in Brazil in 2022.',
    ],
  ),
};

const driverCareerData = <String, DriverCareerProfile>{
  'norris': DriverCareerProfile(
    summary:
        'McLaren graduate who progressed from junior champion to Formula 1 World Champion.',
    achievements: [
      '2025 Formula 1 World Champion',
      '11 Grand Prix wins and 46 podiums',
      'Led McLaren to the 2024 and 2025 Constructors’ titles',
    ],
  ),
  'piastri': DriverCareerProfile(
    summary:
        'One of the fastest-rising drivers of his generation, winning three major junior titles in succession.',
    achievements: [
      'Formula Renault, Formula 3 and Formula 2 champion',
      '9 Grand Prix wins and 28 podiums',
      '2025 World Championship title contender',
    ],
  ),
  'russell': DriverCareerProfile(
    summary:
        'Mercedes junior graduate and proven Grand Prix winner who won GP3 and Formula 2 in consecutive seasons.',
    achievements: [
      '2017 GP3 and 2018 Formula 2 champion',
      '7 Grand Prix wins and 29 podiums',
      'Scored Williams’ first podium since 2017',
    ],
  ),
  'antonelli': DriverCareerProfile(
    summary:
        'Mercedes protégé whose rapid rise included multiple junior championships and an early breakthrough in F1.',
    achievements: [
      '2022 Italian and ADAC Formula 4 champion',
      '2023 Formula Regional Middle East and European champion',
      '5 Grand Prix wins and 10 podiums',
    ],
  ),
  'verstappen': DriverCareerProfile(
    summary:
        'Four-time World Champion who became F1’s youngest starter, points scorer and race winner.',
    achievements: [
      'Four consecutive World Championships from 2021 to 2024',
      '71 Grand Prix wins and 129 podiums',
      'Record 19 victories in the 2023 season',
    ],
  ),
  'hadjar': DriverCareerProfile(
    summary:
        'Red Bull junior who earned promotion after a strong rookie season with Racing Bulls.',
    achievements: [
      '2024 Formula 2 runner-up with four wins',
      'Maiden F1 podium at Zandvoort in 2025',
      'Promoted to Red Bull Racing for 2026',
    ],
  ),
  'leclerc': DriverCareerProfile(
    summary:
        'Ferrari race winner renowned for qualifying speed and victories on the streets of Monaco and Monza.',
    achievements: [
      '2016 GP3 and 2017 Formula 2 champion',
      '9 Grand Prix wins and 53 podiums',
      'Won his home Monaco Grand Prix in 2024',
    ],
  ),
  'hamilton': DriverCareerProfile(
    summary:
        'Seven-time World Champion and the holder of Formula 1’s all-time records for wins and pole positions.',
    achievements: [
      'Seven World Championships',
      'Record 106 Grand Prix wins',
      'Record 104 pole positions and 207 podiums',
    ],
  ),
  'albon': DriverCareerProfile(
    summary:
        'Thai racer who rebuilt his career at Williams after earning podiums with Red Bull.',
    achievements: [
      'Two Formula 1 podiums',
      'Third in the 2018 Formula 2 Championship',
      'Returned to F1 with Williams in 2022',
    ],
  ),
  'sainz': DriverCareerProfile(
    summary:
        'Four-time Grand Prix winner who has scored podiums for McLaren, Ferrari and Williams.',
    achievements: [
      '4 Grand Prix wins and 29 podiums',
      'Ended Red Bull’s 2023 winning streak in Singapore',
      'Put Williams back on the podium in 2025',
    ],
  ),
  'lawson': DriverCareerProfile(
    summary:
        'New Zealand racer who impressed as a substitute before earning a full-time Racing Bulls seat.',
    achievements: [
      '2023 Super Formula runner-up',
      'Scored points in only his third Grand Prix',
      'Career-best Formula 1 finish of fifth',
    ],
  ),
  'lindblad': DriverCareerProfile(
    summary:
        'The sole 2026 rookie and one of the youngest drivers ever promoted to Formula 1.',
    achievements: [
      'Youngest race winner in both Formula 3 and Formula 2',
      '2021 WSK Euro Series karting champion',
      'Formula 1 debut with Racing Bulls in 2026',
    ],
  ),
  'alonso': DriverCareerProfile(
    summary:
        'Two-time World Champion whose career also includes major success in endurance racing.',
    achievements: [
      '2005 and 2006 Formula 1 World Champion',
      '32 Grand Prix wins and 106 podiums',
      'Two-time Le Mans winner and 2018–19 WEC champion',
    ],
  ),
  'stroll': DriverCareerProfile(
    summary:
        'Canadian racer who became the youngest rookie to finish on an F1 podium.',
    achievements: [
      '2016 FIA European Formula 3 champion',
      'Three Formula 1 podiums',
      'Pole position at the 2020 Turkish Grand Prix',
    ],
  ),
  'hulkenberg': DriverCareerProfile(
    summary:
        'Highly experienced German racer, Grand Prix polesitter and Le Mans winner.',
    achievements: [
      '2009 GP2 champion',
      'Won the 2015 Le Mans 24 Hours on debut',
      'Earned his first F1 podium in 2025',
    ],
  ),
  'bortoleto': DriverCareerProfile(
    summary:
        'Brazilian prospect who won Formula 3 and Formula 2 in consecutive rookie campaigns.',
    achievements: [
      '2023 Formula 3 champion',
      '2024 Formula 2 champion',
      'First full-time Brazilian F1 driver since 2017',
    ],
  ),
  'bottas': DriverCareerProfile(
    summary:
        'Ten-time Grand Prix winner and a central contributor to Mercedes’ championship era.',
    achievements: [
      '10 Grand Prix wins and 67 podiums',
      'Drivers’ Championship runner-up in 2019 and 2020',
      'Helped Mercedes win five consecutive Constructors’ titles',
    ],
  ),
  'perez': DriverCareerProfile(
    summary:
        'Mexico’s most successful Formula 1 driver, known for tyre management and street-circuit victories.',
    achievements: [
      '6 Grand Prix wins and 39 podiums',
      '2023 Drivers’ Championship runner-up',
      'First Mexican Grand Prix winner since Pedro Rodriguez',
    ],
  ),
  'gasly': DriverCareerProfile(
    summary:
        'Resilient French Grand Prix winner who rebuilt his career after returning from Red Bull.',
    achievements: [
      '2016 GP2 champion',
      'Won the 2020 Italian Grand Prix',
      '6 Formula 1 podiums',
    ],
  ),
  'colapinto': DriverCareerProfile(
    summary: 'Argentina’s first Formula 1 driver in more than two decades.',
    achievements: [
      'Race winner in Formula 3 and Formula 2',
      'Scored points in his second Formula 1 start',
      'Career-best Formula 1 finish of sixth',
    ],
  ),
  'ocon': DriverCareerProfile(
    summary:
        'Grand Prix winner who rose through the junior ranks despite significant financial obstacles.',
    achievements: [
      '2014 European Formula 3 champion',
      '2015 GP3 champion',
      'Won the 2021 Hungarian Grand Prix',
    ],
  ),
  'bearman': DriverCareerProfile(
    summary:
        'Ferrari junior who scored points on his surprise Formula 1 debut before joining Haas full-time.',
    achievements: [
      '2021 Italian and ADAC Formula 4 champion',
      'Finished seventh on F1 debut for Ferrari in 2024',
      'Career-best fourth place in Mexico in 2025',
    ],
  ),
};
