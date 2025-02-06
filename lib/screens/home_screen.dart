import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_item.dart';
import '../widgets/add_todo_dialog.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.list),
              text: 'Tasks',
            ),
            Tab(
              icon: Icon(Icons.search),
              text: 'Search',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tasks tab
          Consumer<TodoProvider>(
            builder: (context, todoProvider, child) {
              if (todoProvider.selectedTodo != null) {
                // Show dialog for subtask
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  showDialog(
                    context: context,
                    builder: (context) => AddTodoDialog(
                      parent: todoProvider.selectedTodo,
                      onClose: () {
                        todoProvider.setSelectedTodo(null);
                      },
                    ),
                  ).then((_) => todoProvider.setSelectedTodo(null));
                });
              }

              return todoProvider.todos.isEmpty
                  ? const Center(
                      child: Text('No tasks yet'),
                    )
                  : ListView.builder(
                      itemCount: todoProvider.todos.length,
                      itemBuilder: (context, index) {
                        return TodoItem(
                          todo: todoProvider.todos[index],
                        );
                      },
                    );
            },
          ),
          // Search tab
          const SearchScreen(),
        ],
      ),
      floatingActionButton: Consumer<TodoProvider>(
        builder: (context, todoProvider, child) {
          return FloatingActionButton(
            onPressed: todoProvider.selectedTodo == null
                ? () {
                    showDialog(
                      context: context,
                      builder: (context) => const AddTodoDialog(),
                    );
                  }
                : null,
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }
}
