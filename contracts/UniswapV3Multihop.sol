// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.7.6;
pragma abicoder v2;

/// source: https://docs.uniswap.org/protocol/guides/swaps/multihop-swaps

import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';
import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';

contract SwapExamples {
    // В рамках этих примеров подкачки
    // мы подробно расскажем о проектных соображениях при использовании
    // `exactInput`, `exactInputSingle`, `exactOutput` и `exactOutputSingle`.

    // Следует отметить, что в этих примерах мы намеренно передаем маршрутизатор подкачки, а не наследуем его для простоты.
    // В более сложных примерах контрактов будет подробно описано, как безопасно наследовать маршрутизатор подкачки.
    ISwapRouter public immutable swapRouter;

    // В этом примере DAI/WETH9 меняются местами для обмена по одному пути и DAI/USDC/WETH9 для обмена по нескольким путям.

    address public constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public constant WETH9 = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    // For this example, we will set the pool fee to 0.3%.
    uint24 public constant poolFee = 3000;

    constructor(ISwapRouter _swapRouter) {
        swapRouter = _swapRouter;
    }

    /// @notice swapInputMultiplePools обменивает фиксированное количество DAI на максимально возможное количество WETH9 через промежуточный пул.
    /// В этом примере мы заменим DAI на USDC, затем USDC на WETH9, чтобы получить желаемый результат.
    /// @dev Вызывающий адрес должен одобрить этот контракт, чтобы потратить не менее `amountIn` своего DAI, чтобы эта функция выполнилась успешно.
    /// @param amountIn Количество DAI для обмена.
    /// @return amountOut Сумма WETH9, полученная после свопа.
    function swapExactInputMultihop(uint256 amountIn) external returns (uint256 amountOut) {
        // Переносим `amountIn` DAI в этот контракт.
        TransferHelper.safeTransferFrom(DAI, msg.sender, address(this), amountIn);

        // Разрешить маршрутизатору тратить DAI.
        TransferHelper.safeApprove(DAI, address(swapRouter), amountIn);

        // Множественные обмены пула кодируются с помощью байтов, называемых `путь`. Путь — это последовательность адресов токенов и комиссий пула, которые определяют пулы, используемые в свопах.
        // Формат кодирования пула (tokenIn, fee, tokenOut/tokenIn, fee, tokenOut), где параметр tokenIn/tokenOut — общий токен для пулов.
        // Поскольку мы меняем DAI на USDC, а затем USDC на WETH9, кодировка пути (DAI, 0,3%, USDC, 0,3%, WETH9).
        ISwapRouter.ExactInputParams memory params =
            ISwapRouter.ExactInputParams({
                path: abi.encodePacked(DAI, poolFee, USDC, poolFee, WETH9),
                recipient: msg.sender,
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: 0
            });

        // Выполняет обмен.
        amountOut = swapRouter.exactInput(params);
    }

    /// @notice swapExactOutputMultihop обменивает минимально возможное количество DAI на фиксированное количество WETH через промежуточный пул.
    /// В этом примере мы хотим обменять DAI на WETH9 через пул USDC, но мы указываем желаемую сумму из WETH9. Обратите внимание, что кодировка пути немного отличается для точных выходных свопов.
    /// @dev Вызывающий адрес должен одобрить этот контракт, чтобы потратить свой DAI для успешного выполнения этой функции. Поскольку объем входного DAI является переменным,
    /// вызывающий адрес должен будет одобрить немного большую сумму, ожидая некоторых отклонений.
    /// @param amountOut Желаемое количество WETH9.
    /// @param amountInMaximum Максимальное количество DAI, которое можно обменять на указанную сумму Out of WETH9.
    /// @return amountIn Сумма In DAI, фактически потраченная для получения желаемой суммы Out.
    function swapExactOutputMultihop(uint256 amountOut, uint256 amountInMaximum) external returns (uint256 amountIn) {
        // Transfer the specified `amountInMaximum` to this contract.
        TransferHelper.safeTransferFrom(DAI, msg.sender, address(this), amountInMaximum);
        // Approve the router to spend  `amountInMaximum`.
        TransferHelper.safeApprove(DAI, address(swapRouter), amountInMaximum);

        // Путь параметра закодирован как (tokenOut, fee, tokenIn/tokenOut, fee, tokenIn)
        // Поле tokenIn/tokenOut — это общий токен между двумя пулами, используемый при обмене несколькими пулами. В этом случае USDC является «общим» токеном.
        // Для свопа с точного вывода первый своп, который происходит, — это своп, возвращающий возможный желаемый токен.
        // В этом случае наш желаемый выходной токен — WETH9, так что обмен происходит первым и соответственно закодирован в пути.
        ISwapRouter.ExactOutputParams memory params =
            ISwapRouter.ExactOutputParams({
                path: abi.encodePacked(WETH9, poolFee, USDC, poolFee, DAI),
                recipient: msg.sender,
                deadline: block.timestamp,
                amountOut: amountOut,
                amountInMaximum: amountInMaximum
            });

        // Executes the swap, returning the amountIn actually spent.
        amountIn = swapRouter.exactOutput(params);

        // If the swap did not require the full amountInMaximum to achieve the exact amountOut then we refund msg.sender and approve the router to spend 0.
        if (amountIn < amountInMaximum) {
            TransferHelper.safeApprove(DAI, address(swapRouter), 0);
            TransferHelper.safeTransferFrom(DAI, address(this), msg.sender, amountInMaximum - amountIn);
        }
    }
}