import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, int> _emotionCounts = {};
  bool _isLoading = false;
  String _selectedInterval = 'Todo';
  final List<String> _intervals = ['Diario', 'Mensual', 'Anual', 'Todo'];
  DateTime? _selectedDate;
  DateTime? _selectedMonth;
  int? _selectedYear;

  List<String> _parseField(dynamic emociones) {
    if (emociones is List) {
      return emociones.map((e) => e.toString()).toList();
    } else if (emociones is String) {
      return emociones.split(',').map((e) => e.trim()).toList();
    }
    return [];
  }

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      Query<Map<String, dynamic>> query = _firestore.collection(
        'emocionesDetectadas',
      );
      if (_selectedInterval != 'Todo') {
        final now = DateTime.now();
        DateTime startDate;
        DateTime? endDate;
        switch (_selectedInterval) {
          case 'Diario':
            if (_selectedDate == null) {
              startDate = DateTime(now.year, now.month, now.day);
            } else {
              startDate = _selectedDate!;
            }
            endDate = startDate.add(Duration(days: 1));
            break;
          case 'Mensual':
            if (_selectedMonth == null) {
              startDate = DateTime(now.year, now.month, 1);
            } else {
              startDate = DateTime(
                _selectedMonth!.year,
                _selectedMonth!.month,
                1,
              );
            }
            endDate = DateTime(startDate.year, startDate.month + 1, 1);
            break;
          case 'Anual':
            startDate = DateTime(_selectedYear ?? now.year, 1, 1);
            endDate = DateTime((_selectedYear ?? now.year) + 1, 1, 1);
            break;
          default:
            startDate = DateTime(2000);
        }
        if (endDate != null) {
          query = query
              .where(
                'fechaHora',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
              )
              .where('fechaHora', isLessThan: Timestamp.fromDate(endDate));
        } else {
          query = query.where(
            'fechaHora',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
          );
        }
      }
      final snapshot = await query.get();
      final counts = <String, int>{};
      for (final doc in snapshot.docs) {
        for (final emocion in _parseField(doc['emociones'])) {
          counts[emocion] = (counts[emocion] ?? 0) + 1;
        }
      }
      setState(() {
        _emotionCounts = counts;
        _isLoading = false;
      });
    } catch (e) {
      _showError(context, 'Error al cargar datos: ${e.toString()}');
      setState(() => _isLoading = false);
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Color _getEmotionColor(String emocion) {
    switch (emocion.toLowerCase()) {
      case 'tristeza':
      case 'triste':
        return Colors.blue[200]!;
      case 'alegria':
      case 'felicidad':
        return Colors.green[200]!;
      case 'miedo':
        return Colors.purple[200]!;
      case 'incertidumbre':
        return Colors.orange[200]!;
      case 'ira':
      case 'enojo':
        return Colors.red[200]!;
      case 'decepcion':
        return Colors.grey[300]!;
      case 'orgullo':
        return Colors.amber[200]!;
      case 'agotamiento':
        return Colors.brown[200]!;
      case 'cansancio':
        return Colors.grey[400]!;
      case 'frustracion':
        return Colors.deepOrange[200]!;
      case 'sorpresa':
        return Colors.yellow[200]!;
      case 'asco':
        return Colors.teal[200]!;
      case 'neutral':
        return Colors.grey[200]!;
      case 'amor':
      case 'amoroso':
        return Colors.pink[200]!;
      case 'envidia':
        return Colors.lightGreen[200]!;
      case 'calma':
        return Colors.cyan[200]!;
      case 'contento':
        return Colors.lightBlue[200]!;
      case 'ansiedad':
        return Colors.indigo[200]!;
      case 'vergüenza':
        return Colors.brown[300]!;
      default:
        return Colors.grey[200]!;
    }
  }

  List<String> _getRecommendations() {
    final negativeEmotions = ['tristeza', 'miedo', 'incertidumbre'];
    final totalNegative = _emotionCounts.entries
        .where((e) => negativeEmotions.contains(e.key.toLowerCase()))
        .fold(0, (sum, e) => sum + e.value);
    final totalPositive = _emotionCounts['alegria'] ?? 0;

    if (totalNegative > totalPositive && totalNegative > 5) {
      return [
        'Revisar emociones negativas detectadas.',
        'Organizar sesiones de apoyo emocional con los estudiantes.',
        'Implementar actividades para fomentar el bienestar.',
      ];
    } else if (totalPositive > totalNegative) {
      return [
        'Continuar promoviendo un ambiente positivo.',
        'Reforzar actividades que generen alegría.',
        'Monitorear para mantener el equilibrio emocional.',
      ];
    } else {
      return ['Todo en orden. Continuar monitoreando emociones.'];
    }
  }

  Widget _buildBarChart() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    if (_emotionCounts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sentiment_neutral_outlined,
              size: isMobile ? 50 : 60,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'No hay datos de emociones',
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    final barGroups =
        _emotionCounts.entries.toList().asMap().entries.map((entry) {
          final index = entry.key;
          final e = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: e.value.toDouble(),
                color: _getEmotionColor(e.key),
                width: isMobile ? 20 : 30,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList();

    final chartWidth = isMobile ? (_emotionCounts.length * 80.0) : null;

    Widget chartWidget = Container(
      height: isMobile ? 250 : 300,
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[100]!, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barGroups: barGroups,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: isMobile ? 30 : 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: isMobile ? 10 : 12,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final emotion = _emotionCounts.keys.toList()[value.toInt()];
                  return Padding(
                    padding: EdgeInsets.only(top: isMobile ? 4 : 8),
                    child: Transform.rotate(
                      angle: isMobile ? -0.5 : 0.0,
                      child: Text(
                        emotion,
                        style: TextStyle(
                          color: Colors.blue[900],
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 10 : 12,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: false),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final emotion = _emotionCounts.keys.toList()[group.x.toInt()];
                return BarTooltipItem(
                  '$emotion\n${rod.toY.toInt()}',
                  TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 12 : 14,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );

    if (isMobile &&
        chartWidth != null &&
        chartWidth > MediaQuery.of(context).size.width - 40) {
      chartWidget = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(width: chartWidth, child: chartWidget),
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: chartWidget,
    );
  }

  void _showDatePickerDialog() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Container(
              width: isMobile ? double.infinity : 300,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[100]!, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selectedInterval == 'Diario'
                        ? 'Seleccionar Día'
                        : 'Seleccionar Mes',
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: TableCalendar(
                      firstDay: DateTime(2000),
                      lastDay: DateTime.now(),
                      focusedDay:
                          _selectedInterval == 'Diario'
                              ? (_selectedDate ?? DateTime.now())
                              : (_selectedMonth ?? DateTime.now()),
                      calendarFormat:
                          _selectedInterval == 'Diario'
                              ? CalendarFormat.month
                              : CalendarFormat.month,
                      selectedDayPredicate: (day) {
                        if (_selectedInterval == 'Diario') {
                          return _selectedDate != null &&
                              isSameDay(_selectedDate!, day);
                        } else {
                          return _selectedMonth != null &&
                              day.month == _selectedMonth!.month &&
                              day.year == _selectedMonth!.year;
                        }
                      },
                      onDaySelected:
                          _selectedInterval == 'Diario'
                              ? (selectedDay, focusedDay) {
                                setState(() {
                                  _selectedDate = selectedDay;
                                  _selectedMonth = null;
                                  _selectedYear = null;
                                });
                                Navigator.pop(context);
                                _loadDashboardData();
                              }
                              : null,
                      onPageChanged:
                          _selectedInterval == 'Mensual'
                              ? (focusedDay) {
                                setState(() {
                                  _selectedMonth = DateTime(
                                    focusedDay.year,
                                    focusedDay.month,
                                    1,
                                  );
                                  _selectedDate = null;
                                  _selectedYear = null;
                                });
                                Navigator.pop(context);
                                _loadDashboardData();
                              }
                              : null,
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: TextStyle(
                          color: Colors.blue[900],
                          fontSize: isMobile ? 14 : 16,
                        ),
                      ),
                      calendarStyle: CalendarStyle(
                        selectedDecoration: BoxDecoration(
                          color: Colors.blue[700],
                          shape: BoxShape.circle,
                        ),
                        todayDecoration: BoxDecoration(
                          color: Colors.blue[200],
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[700],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isMobile ? 14 : 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _showYearPickerDialog() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final currentYear = DateTime.now().year;
    final years = List.generate(26, (index) => currentYear - index);
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Container(
              width: isMobile ? double.infinity : 300,
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[100]!, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Seleccionar Año',
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                  SizedBox(height: 10),
                  DropdownButton<int>(
                    value: _selectedYear ?? currentYear,
                    items:
                        years
                            .map(
                              (year) => DropdownMenuItem(
                                value: year,
                                child: Text(
                                  year.toString(),
                                  style: TextStyle(color: Colors.blue[900]),
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedYear = value!;
                        _selectedDate = null;
                        _selectedMonth = null;
                      });
                      Navigator.pop(context);
                      _loadDashboardData();
                    },
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      color: Colors.blue[900],
                    ),
                    dropdownColor: Colors.white,
                    underline: Container(height: 2, color: Colors.blue[700]),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[700],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isMobile ? 14 : 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final titleFontSize = isMobile ? 18 : 20;
    final subtitleFontSize = isMobile ? 14 : 16;
    final padding = isMobile ? 10.0 : 20.0;
    final iconSize = isMobile ? 16 : 20;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'DASHBOARD GENERAL',
          style: TextStyle(
            color: Colors.white,
            fontSize: titleFontSize.toDouble(),
          ),
        ),
        backgroundColor: Colors.blue[800],
        elevation: 4,
        automaticallyImplyLeading: false,
      ),
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(color: Colors.blue[700]),
              )
              : Padding(
                padding: EdgeInsets.all(padding),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButton<String>(
                                  value: _selectedInterval,
                                  items:
                                      _intervals
                                          .map(
                                            (interval) => DropdownMenuItem(
                                              value: interval,
                                              child: Text(
                                                interval,
                                                style: TextStyle(
                                                  color: Colors.blue[900],
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedInterval = value!;
                                      if (_selectedInterval == 'Diario' ||
                                          _selectedInterval == 'Mensual') {
                                        _showDatePickerDialog();
                                      } else if (_selectedInterval == 'Anual') {
                                        _showYearPickerDialog();
                                      } else {
                                        _selectedDate = null;
                                        _selectedMonth = null;
                                        _selectedYear = null;
                                        _loadDashboardData();
                                      }
                                    });
                                  },
                                  style: TextStyle(
                                    fontSize: subtitleFontSize.toDouble(),
                                    color: Colors.blue[900],
                                  ),
                                  dropdownColor: Colors.white,
                                  underline: Container(
                                    height: 2,
                                    color: Colors.blue[700],
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              if (_selectedInterval == 'Diario' &&
                                  _selectedDate != null)
                                Expanded(
                                  child: Text(
                                    DateFormat(
                                      'dd/MM/yyyy',
                                    ).format(_selectedDate!),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: subtitleFontSize - 2,
                                    ),
                                  ),
                                ),
                              if (_selectedInterval == 'Mensual' &&
                                  _selectedMonth != null)
                                Expanded(
                                  child: Text(
                                    DateFormat(
                                      'MMMM yyyy',
                                    ).format(_selectedMonth!),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: subtitleFontSize - 2,
                                    ),
                                  ),
                                ),
                              if (_selectedInterval == 'Anual' &&
                                  _selectedYear != null)
                                Expanded(
                                  child: Text(
                                    _selectedYear.toString(),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: subtitleFontSize - 2,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      _buildBarChart(),
                      SizedBox(height: 20),
                      Text(
                        'Recomendaciones',
                        style: TextStyle(
                          fontSize: subtitleFontSize.toDouble(),
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[800],
                        ),
                      ),
                      SizedBox(height: 10),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue[100]!, Colors.white],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: EdgeInsets.all(padding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:
                                _getRecommendations()
                                    .map(
                                      (rec) => Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 4,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.check_circle,
                                              color: Colors.blue[700],
                                              size: iconSize.toDouble(),
                                            ),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                rec,
                                                style: TextStyle(
                                                  fontSize:
                                                      subtitleFontSize - 2,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                    .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
