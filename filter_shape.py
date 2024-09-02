from git_filter_repo import FilterRepo

def filter_files(filename):
    import os
    # Specify the keywords to keep
    keywords = ['powiaty', 'KO', 'pis']
    
    # Keep files only in the 'shape' subfolder that contain the keywords
    if filename.startswith('shape/') and not any(keyword in filename for keyword in keywords):
        return False  # Exclude this file
    return True  # Keep this file

# Set up filter-repo
filter_repo = FilterRepo(
    paths_func=filter_files,
    invert_paths=False
)

filter_repo.run()
