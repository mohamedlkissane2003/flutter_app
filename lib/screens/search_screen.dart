import 'package:flutter/material.dart';
import '../models/movie_model.dart';
import '../models/tv_model.dart';
import '../services/tmdb_api_service.dart';
import '../widgets/movie_card.dart';
import '../widgets/tv_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TmdbApiService _apiService = TmdbApiService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Movie> _movies = [];
  List<TvSeries> _tvSeries = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String _selectedType = 'Films'; // 'Films' ou 'Séries'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _movies = [];
        _tvSeries = [];
        _hasSearched = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      if (_selectedType == 'Films') {
        final movies = await _apiService.searchMovies(query);
        setState(() {
          _movies = movies;
          _tvSeries = [];
          _isLoading = false;
        });
      } else {
        final tvSeries = await _apiService.searchTvSeries(query);
        setState(() {
          _tvSeries = tvSeries;
          _movies = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recherche'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search bar and type selector
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher ${_selectedType.toLowerCase()}...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _performSearch('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                  onSubmitted: _performSearch,
                ),
                const SizedBox(height: 12),
                // Type selector
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.movie, size: 18),
                            SizedBox(width: 4),
                            Text('Films'),
                          ],
                        ),
                        selected: _selectedType == 'Films',
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedType = 'Films';
                            });
                            if (_searchController.text.isNotEmpty) {
                              _performSearch(_searchController.text);
                            }
                          }
                        },
                        selectedColor: Colors.deepPurple,
                        labelStyle: TextStyle(
                          color: _selectedType == 'Films'
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ChoiceChip(
                        label: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.tv, size: 18),
                            SizedBox(width: 4),
                            Text('Séries'),
                          ],
                        ),
                        selected: _selectedType == 'Séries',
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedType = 'Séries';
                            });
                            if (_searchController.text.isNotEmpty) {
                              _performSearch(_searchController.text);
                            }
                          }
                        },
                        selectedColor: Colors.deepPurple,
                        labelStyle: TextStyle(
                          color: _selectedType == 'Séries'
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Results
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : !_hasSearched
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Recherchez des ${_selectedType.toLowerCase()}',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : (_movies.isEmpty && _tvSeries.isEmpty)
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 80,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Aucun résultat trouvé',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.55,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: _selectedType == 'Films'
                                ? _movies.length
                                : _tvSeries.length,
                            itemBuilder: (context, index) {
                              if (_selectedType == 'Films') {
                                return MovieCard(movie: _movies[index]);
                              } else {
                                return TvCard(tvSeries: _tvSeries[index]);
                              }
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
