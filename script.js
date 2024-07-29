const wrapper = document.querySelector('.wrapper');
const signupLink = document.querySelector('.signup-link');


signupLink.addEventListener('click', ()=>{
    wrapper.classList.add('active');
});
