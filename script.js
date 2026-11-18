document.addEventListener('DOMContentLoaded', () => {
    const banner = document.getElementById('cookie-banner');
    const acceptBtn = document.getElementById('accept-cookies');

    // Se o usuário já aceitou anteriormente, oculta o banner imediatamente
    if (localStorage.getItem('tuca_cookies') === 'true') {
        if (banner) {
            banner.style.display = 'none';
        }
    }

    // Adiciona o evento de clique no botão de aceitar para ocultar com animação
    if (acceptBtn && banner) {
        acceptBtn.addEventListener('click', () => {
            localStorage.setItem('tuca_cookies', 'true');
            banner.style.opacity = '0';
            banner.style.transition = 'opacity 0.4s ease';
            setTimeout(() => {
                banner.style.display = 'none';
            }, 400);
        });
    }
});
