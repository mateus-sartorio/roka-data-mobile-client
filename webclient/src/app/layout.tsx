export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html>
      <body style={{ margin: 0, padding: 0 }}>{children}</body>
    </html>
  );
}
