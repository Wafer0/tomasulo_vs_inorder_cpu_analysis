#!/bin/bash
# Script to compile the LaTeX performance report

echo "Compiling LaTeX report..."
echo "========================"

# Check if pdflatex is available
if ! command -v pdflatex &> /dev/null; then
    echo "Error: pdflatex not found. Please install LaTeX (texlive recommended)"
    echo "On Arch Linux: sudo pacman -S texlive-most"
    echo "On Ubuntu/Debian: sudo apt install texlive-latex-extra"
    exit 1
fi

# Compile the report
pdflatex report.tex

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Report compiled successfully!"
    echo "Output: report.pdf"
    echo ""
    echo "To view the PDF:"
    echo "  evince report.pdf    # GNOME"
    echo "  okular report.pdf    # KDE"
    echo "  zathura report.pdf   # Lightweight"
else
    echo ""
    echo "❌ Compilation failed!"
    echo "Check the LaTeX error messages above."
    exit 1
fi
