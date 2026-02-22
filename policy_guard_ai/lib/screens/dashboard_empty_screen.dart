import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardEmptyScreen extends StatelessWidget {
  const DashboardEmptyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {}, // Drawer or menu trigger placeholder
        ),
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Colors.grey.shade200,
              radius: 18,
              child: const Icon(Icons.person_outline, color: Colors.black87),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),

              // Illustration Cluster
              SizedBox(
                height: 160,
                width: 160,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer faint glowing circle
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.05),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: primary.withOpacity(0.1),
                          width: 8,
                        ),
                      ),
                    ),
                    // Inner solid circle
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.security_rounded,
                        size: 48,
                        color: primary,
                      ),
                    ),
                    // Floating Document Icon
                    Positioned(
                      top: 10,
                      right: 15,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.description_outlined,
                          size: 20,
                          color: primary,
                        ),
                      ),
                    ),
                    // Floating Search Icon
                    Positioned(
                      bottom: 20,
                      left: 15,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.search_rounded,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // Text payload
              const Text(
                'No Policies Detected Yet',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'PolicyGuard AI needs data to generate insights. Upload a policy document (PDF, DOCX) to begin the automated scanning process.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),

              // Primary Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/upload'),
                  icon: const Icon(Icons.upload_file_outlined),
                  label: const Text(
                    'Upload Your First Policy',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Secondary Outline Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/onboarding/connect'),
                  icon: Icon(Icons.storage_rounded, color: primary),
                  label: Text(
                    'Connect Database',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: primary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primary,
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              TextButton.icon(
                onPressed: () {},
                icon: const Icon(
                  Icons.help_outline_rounded,
                  size: 16,
                  color: Colors.black54,
                ),
                label: const Text(
                  'View the Setup Guide',
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
